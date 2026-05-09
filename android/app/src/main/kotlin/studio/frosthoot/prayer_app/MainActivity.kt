package studio.frosthoot.prayer_app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {

    companion object {
        private const val SETTINGS_CHANNEL = "studio.frosthoot.prayer_app/settings"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Allow Flutter to draw behind the status bar and navigation bar.
        // WindowCompat.setDecorFitsSystemWindows is the correct call here:
        // AudioServiceActivity's class hierarchy prevents using the
        // ComponentActivity.enableEdgeToEdge() extension at compile time.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)

        // ── PrayerForegroundService start REMOVED in 1.2.1+20 ─────────────
        //
        // The keepalive FGS was causing ForegroundServiceDidNotStartInTime
        // crashes on Android 12-14 due to:
        //   1. Manifest declares `specialUse` (API 34+ feature) but device
        //      OS doesn't fully support it
        //   2. Runtime startForeground() type mismatch with manifest type
        //   3. 5-second deadline race with Flutter engine boot
        //
        // The service was always "best effort" for MIUI/HyperOS notification
        // reliability. Notifications still work via:
        //   - awesome_notifications scheduled exact alarms (primary)
        //   - WorkManager periodic widget update (backup)
        //
        // If MIUI keepalive becomes critical later, re-introduce with:
        //   - Defer FGS start until after Flutter engine is ready
        //   - Use a use-case-appropriate foregroundServiceType
        //   - Or migrate to JobScheduler/WorkManager for the keepalive role
    }

    private fun tryStart(intent: Intent): Boolean = try {
        startActivity(intent); true
    } catch (_: Exception) { false }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBatterySettings" -> {
                        val manufacturer = Build.MANUFACTURER.lowercase()
                        val launched = when {
                            manufacturer == "xiaomi" -> tryStart(Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                                setClassName("com.miui.securitycenter",
                                    "com.miui.permcenter.permissions.PermissionsEditorActivity")
                                putExtra("extra_pkgname", packageName)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            manufacturer == "oppo" -> tryStart(Intent().apply {
                                setClassName("com.coloros.safecenter",
                                    "com.coloros.privacypermissionsentry.PermissionTopActivity")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            manufacturer == "vivo" -> tryStart(Intent().apply {
                                setClassName("com.vivo.permissionmanager",
                                    "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            manufacturer == "huawei" || manufacturer == "honor" -> tryStart(Intent().apply {
                                setClassName("com.huawei.systemmanager",
                                    "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            else -> false
                        }
                        if (!launched) {
                            // Fallback: standard app details page
                            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                        }
                        result.success(null)
                    }
                    "getManufacturer" -> result.success(Build.MANUFACTURER)
                    "openAlarmSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
