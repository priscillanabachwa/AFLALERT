allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
// Ensure all Android library/application modules have a compileSdk set
subprojects {
    project.afterEvaluate {
        try {
            val libExt = extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)
            if (libExt != null) {
                if (libExt.compileSdk == null) {
                    libExt.compileSdk = 34
                }
            }
            val appExt = extensions.findByType(com.android.build.api.dsl.ApplicationExtension::class.java)
            if (appExt != null) {
                if (appExt.compileSdk == null) {
                    appExt.compileSdk = 34
                }
            }
        } catch (e: Exception) {
            // ignore; some projects may not have Android extensions
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
    if (project.name == "tflite_flutter") {
        project.afterEvaluate {
            extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_11
                    targetCompatibility = JavaVersion.VERSION_11
                }
            }

            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}