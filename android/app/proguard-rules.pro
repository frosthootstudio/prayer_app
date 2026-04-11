# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.* { *; }

# Hive
-keep class * extends com.google.flatbuffers.Table { *; }
-keep class * implements com.google.flatbuffers.FlatBufferBuilder { *; }

# Awesome Notifications — keep all classes AND members (reflection-heavy)
-keep class me.carda.awesome_notifications.** { *; }
-keepclassmembers class me.carda.awesome_notifications.** { *; }

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
