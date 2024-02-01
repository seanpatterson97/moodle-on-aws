#!/bin/bash

# Get the repository URL from Terraform statefile
REPOSITORY_URL=$(terraform output -raw ecr_repository_url)

cd app
docker build -t app .
docker tag app:latest ${REPOSITORY_URL}:latest
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPOSITORY_URL}
docker push ${REPOSITORY_URL}:latest
terraform apply -auto-approve