plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Load signing properties if available
val keystoreProperties = Properties().apply {
    val keystoreFile = rootProject.file("key.properties")
    if (keystoreFile.exists()) {
        load(FileInputStream(keystoreFile))
    }
}

android {
    namespace = "com.qayham.qrscanner"

    // Read Flutter SDK config or fallback to compile against SDK 35 for plugin compatibility
    compileSdk = providers.gradleProperty("flutter.compileSdkVersion").map(String::toInt).getOrElse(35)

    defaultConfig {
        applicationId = "com.qayham.qrscanner"
        minSdk = providers.gradleProperty("flutter.minSdkVersion").map(String::toInt).getOrElse(23)
        targetSdk = providers.gradleProperty("flutter.targetSdkVersion").map(String::toInt).getOrElse(35)
        versionCode = providers.gradleProperty("flutter.versionCode").map(String::toInt).getOrElse(13)
        versionName = providers.gradleProperty("flutter.versionName").getOrElse("0.1.1")
    }

    signingConfigs {
        create("release") {
            keystoreProperties["keyAlias"]?.let { keyAlias = it.toString() }
            keystoreProperties["keyPassword"]?.let { keyPassword = it.toString() }
            keystoreProperties["storeFile"]?.let { storeFile = file(it.toString()) }
            keystoreProperties["storePassword"]?.let { storePassword = it.toString() }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}

dependencies {
  implementation("com.google.android.gms:play-services-ads:24.5.0")
}