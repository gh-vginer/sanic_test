// USE THE CORRECT LIBRARY TO BUILD FROM. FOR A TAGGED VERSION TO BE BUILD USE THE CORRESPONDING VERSION of shared library.
library "common-code@${'master'}" _

pipeline {
    agent { label 'bazel-server' }
    
    environment {
        REGISTRY = globals.get_docker_internal_artifactory_repository()
        GIT_BRANCH = utility.get_git_branch_edited(env.BRANCH_NAME)
        IMAGE_NAME = "${REGISTRY}/cleaner:${GIT_BRANCH}_${env.BUILD_NUMBER}"
        FINAL_IMAGE = "${REGISTRY}/cleaner:${GIT_BRANCH}_latest"
        NUM_OLD_BUILDS = globals.get_num_oldbuild()
        PRODUCTION_REGISTRY = globals.get_docker_production_artifactory_repository()
        PRODUCTION_IMAGE_BASE = "${PRODUCTION_REGISTRY}/cleaner"
        scannerHome = tool 'SonarQubeScanner4'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr:env.NUM_OLD_BUILDS))
    }
    
    stages {
      stage("Build and push images") {
        steps {
          script {
            utility.login_docker_internal_artifactory_repository()  
            sh """
                docker build -t ${IMAGE_NAME} -f prod.Dockerfile .
                docker push ${IMAGE_NAME}
                docker tag ${IMAGE_NAME} ${FINAL_IMAGE}
                docker push ${FINAL_IMAGE}
            """    
          }
        }
      }
        
      stage ('Deploy Production Container') {
            when {
                expression { return ((env.BRANCH_NAME ==~ /.*-RLS\d*/) || env.BRANCH_NAME ==~ /.*-RC\d+/) }
            }
            steps {
                script {
                    PRODUCTION_IMAGE = "${PRODUCTION_REGISTRY}/cleaner:${GIT_BRANCH}"
                    utility.login_docker_production_artifactory_repository()
                    sh """
                        docker tag ${FINAL_IMAGE} ${PRODUCTION_IMAGE}
                        docker push ${PRODUCTION_IMAGE}
                    """
                }
            }
        }  
    }

    post {
        success {
            sendNotifications 'SUCCESS'
        }
        failure {
            sendNotifications 'FAILED'
                emailext (
                    subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                    <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
                    recipientProviders: [[$class: 'CulpritsRecipientProvider']]
                )
        }
    }
}
