pluginManagement {
    // 🔧 تحديد مسار Flutter SDK تلقائياً من local.properties
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdk = properties.getProperty("flutter.sdk")
        require(flutterSdk != null) { "flutter.sdk not set in local.properties" }
        flutterSdk
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    // هذا الـ plugin يأتي مع Flutter SDK ويجب أن يكون أولاً
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // احرص على تطابق الإصدارات مع الـ build.gradle.kts في الجذر
    id("com.android.application") version "8.6.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

