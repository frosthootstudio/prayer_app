package studio.frosthoot.prayer_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class PrayerForegroundService : Service() {

    /**
     * Calls startForeground() with the explicit foregroundServiceType matching
     * the AndroidManifest declaration (specialUse). Required by Android 14+
     * to avoid SecurityException, and recommended on Android 10-13 for the
     * 5-second startForeground deadline.
     *
     * Wrapped in try/catch because OEMs (especially Xiaomi/MIUI) sometimes
     * block FGS starts in the background — failing here should not crash
     * the app since the service is best-effort keepalive.
     *
     * Resolves Crashlytics: ForegroundServiceDidNotStartInTimeException
     * (1.1.6+17, 1 user, Pixel 6 Pro Android 12).
     */
    override fun onCreate() {
        super.onCreate()
        try {
            val notification = buildNotification()
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE -> {
                    // Android 14+ — type MUST match manifest (specialUse)
                    startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                    )
                }
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                    // Android 10-13 — pass type for stability; specialUse not
                    // available below API 34 so use dataSync (safe, available
                    // since API 29 and matches notification keepalive purpose).
                    startForeground(
                        NOTIFICATION_ID,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                    )
                }
                else -> {
                    startForeground(NOTIFICATION_ID, notification)
                }
            }
        } catch (e: Exception) {
            // OEM block (Xiaomi/MIUI bg-restriction), notification permission
            // denied, etc. App still works; service is best-effort.
            Log.w(TAG, "startForeground failed (non-fatal): $e")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // START_STICKY: system restarts service if killed, keeping scheduler alive
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildNotification(): Notification {
        val channelId = "prayer_keepalive"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Waktu Shalat Aktif",
                NotificationManager.IMPORTANCE_MIN
            ).apply {
                setShowBadge(false)
                description = "Layanan latar belakang pengingat shalat"
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Waktu Shalat aktif")
            .setContentText("Pengingat adzan berjalan di latar belakang")
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSilent(true)
            .setOngoing(true)
            .setVisibility(NotificationCompat.VISIBILITY_SECRET)
            .build()
    }

    companion object {
        const val NOTIFICATION_ID = 9999
        private const val TAG = "PrayerForegroundService"
    }
}
