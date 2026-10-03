import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Both the properties file and keystore must remain outside this checkout.
val signingPath = System.getenv("EXQUISSSITA_SIGNING_PROPERTIES")
val signingProperties = Properties()
val checkout = rootProject.projectDir.parentFile.canonicalFile.toPath()
if (!signingPath.isNullOrBlank()) {
    val configFile = file(signingPath).canonicalFile
    require(java.io.File(signingPath).isAbsolute && !configFile.toPath().startsWith(checkout)) {
        "Release signing properties must be outside the repository."
    }
    require(configFile.isFile) { "Release signing properties file is missing." }
    configFile.inputStream().use { signingProperties.load(it) }
    listOf("storeFile", "storePassword", "keyAlias", "keyPassword").forEach {
        require(!signingProperties.getProperty(it).isNullOrBlank()) { "Release signing field is missing: $it" }
    }
    val keystore = file(signingProperties.getProperty("storeFile")).canonicalFile
    require(java.io.File(signingProperties.getProperty("storeFile")).isAbsolute && keystore.isFile && !keystore.toPath().startsWith(checkout)) {
        "Release keystore must exist outside the repository."
    }
}
val releaseRequested = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }
require(!releaseRequested || !signingPath.isNullOrBlank()) {
    "Release requires EXQUISSSITA_SIGNING_PROPERTIES. See docs/platform-hardening.md."
}
gradle.taskGraph.whenReady { graph ->
    require(!graph.allTasks.any { it.project == project && it.name.contains("release", ignoreCase = true) } || !signingPath.isNullOrBlank()) {
        "Release requires external signing configuration. See docs/platform-hardening.md."
    }
}

android {
    namespace = "com.mirandadevsource.exquisssita"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Se mantiene consistente con el paquete principal del Flutter Activity.
        applicationId = "com.mirandadevsource.exquisssita"
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Android 6.0+ requerido por mobile_scanner y flutter_secure_storage
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (!signingPath.isNullOrBlank()) {
            create("release") {
                storeFile = file(signingProperties.getProperty("storeFile"))
                storePassword = signingProperties.getProperty("storePassword")
                keyAlias = signingProperties.getProperty("keyAlias")
                keyPassword = signingProperties.getProperty("keyPassword")
            }
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
