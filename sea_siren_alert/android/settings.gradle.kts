pluginManagement {
    def flutterPluginVersion = '0.0.37'
    plugins {
        id 'dev.flutter.flutter-gradle-plugin' version flutterPluginVersion
    }
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id 'dev.flutter.flutter-gradle-plugin'
}

rootProject.name = 'sea_siren_alert'
include ':app'