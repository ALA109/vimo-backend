plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // يجب أن يأتي Flutter plugin بعد Android + Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.vimo.vimo"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.vimo.vimo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // توقيع مؤقت بمفاتيح debug
            signingConfig = signingConfigs.getByName("debug")

            // عطّل التصغير وتقليص الموارد أثناء التطوير
            isMinifyEnabled = false
            isShrinkResources = false   // ← هذا هو التصحيح المهم

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            applicationIdSuffix = ".debug"
            // لا تضف debuggable هنا؛ Android يفعّلها تلقائيًا في debug
        }
    }

    packaging {
        resources.excludes += setOf(
            "META-INF/LICENSE",
            "META-INF/DEPENDENCIES",
            "META-INF/NOTICE"
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.23")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")

    // Material 3
    implementation("com.google.android.material:material:1.12.0")
}
