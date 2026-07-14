package studio.frosthoot.prayer_app

import android.content.ComponentName
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
    }

    private fun tryStart(intent: Intent): Boolean = try {
        startActivity(intent); true
    } catch (_: Exception) { false }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Start keepalive foreground service for MIUI/HyperOS reliability so
        // scheduled adzan alarms keep firing when the app is backgrounded.
        val serviceIntent = Intent(this, PrayerForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }

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
                    "openAutostartSettings" -> {
                        result.success(openAutostartSettings())
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Opens the OEM autostart / background-launch manager. On Xiaomi/MIUI this
     * is the single most important toggle for reliable notifications after the
     * app is swiped from recents or the device reboots. Falls back through
     * generic MIUI intents, then the app details page.
     */
    private fun openAutostartSettings(): Boolean {
        val miuiIntent = Intent().apply {
            component = ComponentName(
                "com.miui.securitycenter",
                "com.miui.permcenter.autostart.AutoStartManagementActivity",
            )
        }
        if (tryStart(miuiIntent.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) })) return true
        val legacyIntent = Intent("miui.intent.action.OP_AUTO_START").apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        if (tryStart(legacyIntent)) return true
        return tryStart(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        })
    }
}
