#!/bin/bash
set -e

EC2_HOST="13.220.55.228"
EC2_USER="ubuntu"
KEY_PATH="~/.ssh/testing.pem"
IMAGE_NAME="hammad2005/docker-cicd-demo"
BUILD_NUMBER=${BUILD_NUMBER:-latest}

echo "Deploying to EC2 instance: ${EC2_HOST}"

ssh -i ${KEY_PATH} -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << ENDSSH
    sudo apt-get update

    if ! command -v docker &> /dev/null; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker ubuntu
    fi

    docker pull ${IMAGE_NAME}:${BUILD_NUMBER}
    docker stop docker-cicd-prod || true
    docker rm docker-cicd-prod || true
    docker run -d --name docker-cicd-prod -p 80:3000 --restart unless-stopped ${IMAGE_NAME}:${BUILD_NUMBER}

    sleep 10
    curl -f http://localhost/health || exit 1
    echo "Deployment completed successfully!"
ENDSSH
