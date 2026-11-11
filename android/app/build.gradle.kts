import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Flutter passes build-time defines as base64 entries. Keep Maps keys out of Git.
val buildDefines = (project.findProperty("dart-defines") as? String).orEmpty()
    .split(",").filter { it.isNotEmpty() }.associate {
        val entry = String(Base64.getDecoder().decode(it)).split("=", limit = 2)
        entry[0] to entry.getOrElse(1) { "" }
    }

android {
    namespace = "lk.contractor.contractor_app"
    compileSdk = flutter.compileSdkVersion
    // Both Android plugins require this NDK version.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "lk.contractor.contractor_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        manifestPlaceholders["mapsApiKey"] = buildDefines["GOOGLE_MAPS_API_KEY"].orEmpty()
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
