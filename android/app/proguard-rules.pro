# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.* { *; }

# Hive
-keep class * extends com.google.flatbuffers.Table { *; }
-keep class * implements com.google.flatbuffers.FlatBufferBuilder { *; }

# Awesome Notifications — keep EVERYTHING (reflection-heavy plugin).
# Crashlytics still showed ClassNotFoundException across 31 users in 1.1.2-
# 1.2.1 despite wildcard + interface + enum keeps. Adding EXPLICIT keep for
# each receiver/service declared in the merged AndroidManifest — Android
# instantiates these by class name string, so any R8 rename/strip breaks
# them. Belt-and-suspenders: explicit + wildcard + dontwarn.
#
# List sourced from:
#   build/app/intermediates/merged_manifests/release/processReleaseManifest/
#   AndroidManifest.xml (grep me.carda.awesome_notifications)
#
# If awesome_notifications package adds NEW receivers in future versions,
# this list needs to grow. Re-grep merged manifest after plugin upgrade.

-keep class me.carda.awesome_notifications.core.broadcasters.receivers.DartBackgroundService { *; }
-keep class me.carda.awesome_notifications.DartNotificationActionReceiver { *; }
-keep class me.carda.awesome_notifications.DartDismissedNotificationReceiver { *; }
-keep class me.carda.awesome_notifications.DartScheduledNotificationReceiver { *; }
-keep class me.carda.awesome_notifications.DartRefreshSchedulesReceiver { *; }
-keep class me.carda.awesome_notifications.DartBackgroundService { *; }
-keep class me.carda.awesome_notifications.core.services.ForegroundService { *; }
-keep class me.carda.awesome_notifications.core.managers.StatusBarManager { *; }

# Catch-all wildcards (defense in depth) — keeps all other internal classes
# the plugin loads via reflection (managers, models, channels, etc.)
-keep class me.carda.awesome_notifications.** { *; }
-keep interface me.carda.awesome_notifications.** { *; }
-keep enum me.carda.awesome_notifications.** { *; }
-keepclassmembers class me.carda.awesome_notifications.** { *; }
-keepclassmembers interface me.carda.awesome_notifications.** { *; }
-dontwarn me.carda.awesome_notifications.**

# Defensive — keep all Service/BroadcastReceiver/ContentProvider subclasses.
# These are instantiated by the Android system via class name lookup from
# AndroidManifest entries; obfuscation breaks that lookup.
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends androidx.work.Worker
-keep public class * extends androidx.work.ListenableWorker

# Home Widget
-keep class es.antonborri.home_widget.** { *; }

# Workmanager
-keep class be.tramckrijte.workmanager.** { *; }

# Just Audio — uses Media3 (ExoPlayer3) since just_audio 0.10.x.
# Keep both namespaces: Media3 is the active one; the legacy rule is harmless.
-keep class androidx.media3.** { *; }
-keepclassmembers class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# just_audio & just_audio_background native glue
-keep class com.ryanheise.just_audio.** { *; }
-keepclassmembers class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audioservice.** { *; }
-keepclassmembers class com.ryanheise.audioservice.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# App model classes
-keep class studio.frosthoot.prayer_app.** { *; }

# Flutter Play Core (not used but referenced — suppress R8 warnings)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
