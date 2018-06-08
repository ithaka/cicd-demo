podTemplate(label: 'test', cloud: 'kubernetes',
        containers: [
                containerTemplate(name: 'docker', image: 'docker', ttyEnabled: true, command: 'cat'),
                containerTemplate(name: 'kubectl', image: 'dtzar/helm-kubectl', ttyEnabled: true, command: 'cat'),
                containerTemplate(name: 'node-alpine', image:'node:10.1.0-alpine', ttyEnabled: true, command: 'cat')
        ], volumes: [hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')]){

    node("test") {
      source_code = checkout(scm)
      GIT_COMMIT = source_code.GIT_COMMIT.substring(0, 6).toLowerCase()
      GIT_BRANCH = source_code.GIT_BRANCH.replaceAll('origin/', '').toLowerCase()
      VERSION_IDENTIFIER = "${GIT_BRANCH}-${GIT_COMMIT}"
      APP_DOCKER_TAG = "cicd-demo:${VERSION_IDENTIFIER}"
      TESTS_DOCKER_TAG = "cicd-demo-tests:${VERSION_IDENTIFIER}"
      try{
          container('docker'){
            parallel(
              'buildApp': {stage('build app'){
                sh "docker build -f ./hello-world/src/Dockerfile -t ${APP_DOCKER_TAG}  ./hello-world/src"
              }},
              'buildTests': {stage('build tests'){
                sh "docker build -f ./hello-world/integration/Dockerfile -t ${TESTS_DOCKER_TAG} ./hello-world/integration"
              }}
            )
          }
          container('kubectl'){
            stage('deploy app'){
                sh "helm upgrade --install --force --service-account tiller --tiller-namespace default --values ./hello-world/chart/values.yaml --set tag=${VERSION_IDENTIFIER} hello-world-app-${GIT_BRANCH} ./hello-world/chart"
            }
          }
          parallel(
            'unitTests': {stage('unit tests'){
                container('node-alpine'){
                    sh 'cd hello-world/src && npm install && npm run test'
                }
            }},
            'integrationTests': {stage('integration tests'){
                container('kubectl'){
                    sh "kubectl run --env=\"BASE_URL=http://cicd-demo-service:3000\" cicd-demo-integration-tests-${GIT_COMMIT} --image=${TESTS_DOCKER_TAG} --restart=\"Never\""
                }
            }}
          )
          timeout(time: 300, unit: 'SECONDS') {
              input(id: 'Proceed1', message: 'Was this successful?',
                    parameters: [
                      [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Please confirm that this deployment succeeded']
                    ])
          }
          container('kubectl'){
                stage('undeploy app'){
                    sh "SERVICE_ACCOUNT_NAME=tiller; helm delete --tiller-namespace default hello-world-app-${GIT_BRANCH}"
                }
                stage('deploy to prod'){
                    sh "helm upgrade --service-account tiller --install --force --tiller-namespace default --namespace prod --values ./hello-world/chart/values.yaml --set tag=${VERSION_IDENTIFIER} hello-world-app ./hello-world/chart"
                }
            }


      }
      catch(e){
        container('kubectl'){
            stage('undeploy app'){
                sh "SERVICE_ACCOUNT_NAME=tiller; helm delete --tiller-namespace default hello-world-app-${GIT_BRANCH}"
            }
        }
        throw e
      }
    }
}
