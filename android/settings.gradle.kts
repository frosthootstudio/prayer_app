pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    // KGP version declaration retained for the 11 plugins that still apply
    // kotlin-android explicitly (audio_session, audioplayers_android,
    // firebase_analytics, flutter_compass_v2, flutter_qiblah, home_widget,
    // in_app_review, package_info_plus, share_plus, webview_flutter_android,
    // workmanager_android). The app module itself no longer applies KGP —
    // Flutter's built-in Kotlin handles it. Remove this line once all
    // plugins are migrated (C.2-C.5).
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    // Firebase plugins
    id("com.google.gms.google-services") version "4.4.2" apply false
    id("com.google.firebase.crashlytics") version "3.0.2" apply false
}

include(":app")
