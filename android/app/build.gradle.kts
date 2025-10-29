plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Add Google Services Plugin
    id("com.google.firebase.crashlytics") // Add Crashlytics Plugin
}

android {
    namespace = "com.live.ai.sermon"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.live.ai.sermon"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
        versionCode = 35
        versionName = "1.4.3"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.android.billingclient:billing:7.1.1")
    implementation("com.facebook.android:facebook-android-sdk:17.0.2")
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.15.0"))
    // Firebase dependencies (version managed by BoM)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-crashlytics")
    // Google Play Services for Amplitude App Set ID
    implementation("com.google.android.gms:play-services-appset:16.0.2")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}