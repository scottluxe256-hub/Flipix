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
            implementation("org.jetbrains.compose.runtime:runtime:1.11.1")
            implementation("org.jetbrains.compose.foundation:foundation:1.11.1")
            implementation(
                "org.jetbrains.compose.material3:material3:1.11.0-alpha07"
            )
            implementation(
                "org.jetbrains.compose.components:components-resources:1.11.1"
            )

            implementation(
                "io.github.kdroidfilter:composemediaplayer:0.11.4"
            )
            implementation(
                "io.github.kdroidfilter:composemediaplayer-audio:0.11.4"
            )
        }

        androidMain.dependencies {
            implementation("androidx.activity:activity-compose:1.12.0")
        }

        getByName("desktopMain").dependencies {
            // PERBAIKAN 1: Gunakan implementation(...) standar
            implementation(compose.desktop.currentOs)
        }
    }
}

android {
    namespace = "com.flipfix"

    compileSdk = 36

    defaultConfig {
        applicationId = "com.flipfix"
        minSdk = 23
        targetSdk = 36

        versionCode = 1
        versionName = "1.0"
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

                val logoFile =
                    project.file(
                        "src/desktopMain/resources/logo.ico"
                    )

                // PERBAIKAN 2: Gunakan assignment langsung
                if (logoFile.exists()) {
                    iconFile = logoFile
                }
            }
        }
    }
}
