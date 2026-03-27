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
                script {
                    docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }

        stage('Security Scan') {
            steps {
                echo 'Running security scan...'
                sh '''
                    trivy image --exit-code 0 --severity HIGH,CRITICAL ${DOCKER_IMAGE}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS) {
                        def image = docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                        image.push()
                        image.push("latest")
                        def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                        image.push(gitCommit.take(8))
                    }
                }
            }
        }

        stage('Deploy to ec2') {
            steps {
                echo 'Deploying to staging environment...'
                sh '''
                    docker stop docker-cicd-staging || true
                    docker rm docker-cicd-staging || true
                    docker run -d --name docker-cicd-staging -p 3001:3000 ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    sleep 10
                    curl -f http://localhost:3001/health || exit 1
                '''
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
