pipeline {
    agent any

    environment {
        DOCKERHUB_USER = "lakshvar96"
        FRONTENDIMAGE = "ems1"
        BACKENDIMAGE = "ems2"
        GIT_REPO = "https://github.com/Lakshmanan1996/EmployeManagementSystem.git"
    }

    tools {
        maven 'maven'
    }

    stages {

        /* ===================== CHECKOUT ===================== */

        stage('Checkout') {
            steps {
                git branch: 'master', url: "${GIT_REPO}"
            }
        }

        /* ===================== Build Maven single Stage ===================== */
        stage('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }


        /* ===================== SONARQUBE ===================== */
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=EMS \
                    -Dsonar.java.binaries=target
                    '''
                }
            }
        }

         /*===================== QUALITY GATE ===================== */

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* ===================== DOCKER BUILD ===================== */

        stage('Docker Build') {
            steps {
                sh """
                docker build -t ${DOCKERHUB_USER}/${FRONTENDIMAGE}:${BUILD_NUMBER} ./cms
                docker build -t ${DOCKERHUB_USER}/${BACKENDIMAGE}:${BUILD_NUMBER} .
                """
            }
        }

        /* ===================== TRIVY SCAN ===================== */

        stage('Trivy Scan') {
            steps {
                sh """
                trivy image ${DOCKERHUB_USER}/${FRONTENDIMAGE}:${BUILD_NUMBER}
                trivy image ${DOCKERHUB_USER}/${BACKENDIMAGE}:${BUILD_NUMBER}
                """
            }
        }


        /* ===================== PUSH TO DOCKER HUB ===================== */

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image') {
            steps {
                sh """
                docker push ${DOCKERHUB_USER}/${FRONTENDIMAGE}:${BUILD_NUMBER}
                docker push ${DOCKERHUB_USER}/${BACKENDIMAGE}:${BUILD_NUMBER}
                """
            }
        }
    }


    post {
        success {
            echo "✅ EMS CICD Pipeline SUCCESS"
        }
        failure {
            echo "❌ EMS CICD Pipeline FAILED"
        }
    }
}
