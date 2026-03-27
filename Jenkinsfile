pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'hammad2005/docker-cicd-demo'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh './build-docker.sh'
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running security scan...'
                sh "./security-scan.sh ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Docker Hub image...'
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh './push-docker.sh'
                }
            }
        }

        stage('Deploy to EC2 & Verify') {
            steps {
                echo 'Deploying to EC2 and checking app status...'
                sshagent(['ec2-key']) {  // Your Jenkins SSH credential ID
                    sh """
                        chmod +x deploy-to-ec2.sh
                        ./deploy-to-ec2.sh
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up local Docker system...'
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
