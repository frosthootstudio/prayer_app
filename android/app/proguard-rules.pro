# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.* { *; }

# Hive
-keep class * extends com.google.flatbuffers.Table { *; }
-keep class * implements com.google.flatbuffers.FlatBufferBuilder { *; }

# Awesome Notifications — keep all classes AND members (reflection-heavy).
# Crashlytics 2026-05-01 showed ClassNotFoundException for
# me.carda.awesome_notifications.core.broadcasters.* across 14 users in
# 1.1.2-1.1.5 — receivers loaded by Android system at BOOT_COMPLETED /
# MY_PACKAGE_REPLACED. The wildcard keep below SHOULD cover it, but adding
# broader defense for any plugin-registered Service/Receiver/Provider as
# safety net — these are referenced from AndroidManifest by name and break
# silently if R8 renames them.
-keep class me.carda.awesome_notifications.** { *; }
-keepclassmembers class me.carda.awesome_notifications.** { *; }

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
