buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val forceSdkVersion = { project: Project ->
        val extension = project.extensions.findByName("android")
        if (extension is com.android.build.gradle.BaseExtension) {
            extension.compileSdkVersion(36)
            extension.defaultConfig.targetSdkVersion(36)
        }
    }

    if (state.executed) {
        forceSdkVersion(this)
    } else {
        afterEvaluate {
            forceSdkVersion(this)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
