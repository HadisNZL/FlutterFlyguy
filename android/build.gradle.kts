allprojects {
    repositories {
        google()
        mavenCentral()
        // HL Maven 仓库
        maven {
            url = uri("https://hualai-foreign-maven.hualaikeji.com/repository/smart_group/")
            isAllowInsecureProtocol = false
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
