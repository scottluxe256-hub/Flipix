import org.jetbrains.compose.desktop.application.dsl.TargetFormat
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    kotlin("multiplatform")
    id("com.android.application")
    id("org.jetbrains.compose")
    id("org.jetbrains.kotlin.plugin.compose")
}

group = "com.flipfix"
version = "1.0.0"

kotlin {
    jvmToolchain(21)

    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_21)
        }
    }

    jvm("desktop")

    sourceSets {
        commonMain.dependencies {
            implementation(compose.runtime)
            implementation(compose.foundation)
            implementation(compose.material3)

            implementation("io.github.kdroidfilter:composemediaplayer:0.11.4")
            implementation("io.github.kdroidfilter:composemediaplayer-audio:0.11.4")
        }

        androidMain.dependencies {
            implementation("androidx.activity:activity-compose:1.9.3")
        }

        getByName("desktopMain").dependencies {
            implementation(compose.desktop.currentOs)
        }
    }
}

android {
    namespace = "com.flipfix"
    compileSdk = 36 // <-- Diubah dari 35 ke 36

    defaultConfig {
        applicationId = "com.flipfix"
        minSdk = 23
        targetSdk = 35

        versionCode = 1
        versionName = "1.0"
    }

    sourceSets {
        getByName("main") {
            assets.srcDirs("src/androidMain/assets")
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
        }

        release {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            excludes += "/META-INF/INDEX.LIST"
            excludes += "/META-INF/io.netty.versions.properties"
        }
    }
}

compose.desktop {
    application {
        mainClass = "flipfix.MainKt"

        nativeDistributions {
            targetFormats(
                TargetFormat.Exe,
                TargetFormat.Msi
            )

            packageName = "FlipFix"
            packageVersion = "1.0.0"

            description = "FlipFix Memory Match Game"
            vendor = "FlipFix"

            windows {
                console = false
                dirChooser = true
                perUserInstall = true

                val logoFile = project.file("src/desktopMain/resources/logo.ico")
                if (logoFile.exists()) {
                    iconFile = logoFile
                }
            }
        }
    }
}
