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
        // Start keepalive foreground service so MIUI/HyperOS won't kill
        // the notification scheduler when the app is in the background.
        val serviceIntent = Intent(this, PrayerForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
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
