plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // استخدمنا com.alaa.cv_app بناءً على مشروعك الحالي
    namespace = "com.alaa.cv_app"
    
    // الحل الجذري: نحدد 36 يدوياً لأن المكتبات في صورك طلبت ذلك صراحة
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.alaa.cv_app"
        
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // تأكد أن ملف upload-keystore.jks موجود فعلياً في مجلد android/app
            storeFile = file("upload-keystore.jks") 
            storePassword = "alaa123459" 
            keyAlias = "upload"
            keyPassword = "alaa123459"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            // يفضل تعطيل الـ Minify مؤقتاً لضمان نجاح البناء
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// الجزء الأهم لحل مشكلة lStar وتكرار الكلاسات التي ظهرت في صورك
configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.activity:activity:1.8.2")
        force("androidx.activity:activity-ktx:1.8.2")
    }
}

flutter {
    source = "../.."
}