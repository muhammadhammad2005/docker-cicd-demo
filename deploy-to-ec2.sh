#!/bin/bash
set -e

EC2_HOST="13.220.55.228"
EC2_USER="ubuntu"
IMAGE_NAME="hammad2005/docker-cicd-demo"
BUILD_NUMBER=${BUILD_NUMBER:-latest}

echo "Deploying to EC2 instance: ${EC2_HOST}"

ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << ENDSSH

    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
    fi

    echo "Pulling latest image..."
    sudo docker pull ${IMAGE_NAME}:${BUILD_NUMBER}

    echo "Stopping old container..."
    sudo docker stop docker-cicd-prod || true
    sudo docker rm docker-cicd-prod || true

    echo "Starting new container..."
    sudo docker run -d \
        --name docker-cicd-prod \
        -p 80:3000 \
        --restart unless-stopped \
        ${IMAGE_NAME}:${BUILD_NUMBER}

    echo "Waiting for app..."
    sleep 10

    echo "Running health check..."
    curl -f http://localhost/health || exit 1

    echo "Deployment completed successfully!"

ENDSSH
