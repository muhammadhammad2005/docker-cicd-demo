#!/bin/bash
set -e

IMAGE_NAME="hammad2005/docker-cicd-demo"
BUILD_NUMBER=${BUILD_NUMBER:-latest}
GIT_COMMIT=${GIT_COMMIT:-$(git rev-parse HEAD)}

echo "Logging into Docker Hub..."
echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

echo "Pushing Docker images..."
docker push ${IMAGE_NAME}:${BUILD_NUMBER}
docker push ${IMAGE_NAME}:latest
docker push ${IMAGE_NAME}:${GIT_COMMIT:0:8}

echo "Images pushed successfully!"
