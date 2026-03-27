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
                sh '''
                    chmod +x build-docker.sh
                    ./build-docker.sh
                '''
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running security scan...'
                sh '''
                    chmod +x security-scan.sh
                    ./security-scan.sh ${DOCKER_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS) {
                        sh '''
                            chmod +x push-docker.sh
                            ./push-docker.sh
                        '''
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo 'Deploying to EC2...'
                sshagent(['ec2-key']) {
                    sh '''
                        chmod +x deploy-to-ec2.sh
                        ./deploy-to-ec2.sh
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
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
