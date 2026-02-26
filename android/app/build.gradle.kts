import java.util.Properties
import java.io.FileInputStream

// 1. قراءة ملف التوقيع (Signing Config)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.alaa.cv_app"
    
    // التعديل الجوهري: رفع compileSdk لـ 36 لحل تعارض المكتبات الظاهر في صورك
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "com.alaa.cv_app"
        // رفع minSdk لـ 24 لضمان توافق المكتبات الحديثة
        minSdk = 24
        // رفع المستهدف لـ 36 تماشياً مع طلب الـ Gradle في الصور
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// حل مشكلة "lStar not found" وتعارض نسخ المكتبات (إجبار المشروع على نسخ مستقرة)
configurations.all {
    resolutionStrategy {
        force("androidx.core:core-ktx:1.15.0")
        force("androidx.activity:activity-ktx:1.9.3")
    }
}

flutter {
    source = "../.."
}