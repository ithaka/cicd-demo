podTemplate(label: 'test', cloud: 'kubernetes',
        containers: [
                containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat'),
                containerTemplate(name: 'kubectl', image: 'dtzar/helm-kubectl', ttyEnabled: true, command: 'cat')
        ], volumes: [hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')]){

    node("test") {
      source_code = checkout(scm)
      GIT_COMMIT = source_code.GIT_COMMIT.substring(0, 6).toLowerCase()
      GIT_BRANCH = source_code.GIT_BRANCH.replaceAll('origin/', '').toLowerCase()
      VERSION_IDENTIFIER = "${GIT_BRANCH}-${GIT_COMMIT}"
      container('docker'){
        parallel{
          stage('build app'){
            sh 'docker build -f ./hello-world/src/Dockerfile' ./hello-world/src
          }
          stage('build tests'){
            sh 'docker build -f ./hello-world/integration/Dockerfile' ./hello-world/integration
          }
        }
      }
    }
}