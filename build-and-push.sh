#!/bin/bash

#hash seeded with timestamp to avoid conflicts
HASH=$(date +%Y%m%d%H%M%S)

# Get the repository URL from Terraform statefile
REPOSITORY_URL=$(terraform output -raw ecr_repository_url)

cd app
docker build -t app .
docker tag app:latest ${REPOSITORY_URL}:latest
docker tag app:latest ${REPOSITORY_URL}:${HASH}
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPOSITORY_URL}
docker push ${REPOSITORY_URL}:latest
docker push ${REPOSITORY_URL}:${HASH}