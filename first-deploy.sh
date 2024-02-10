#!/bin/bash

terraform init
terraform apply -target=aws_ecr_repository.ecr -auto-approve -var="moodle_skip_install=false"

# hash seeded with timestamp to avoid conflicts
HASH=$(date +%Y%m%d%H%M%S)
REPOSITORY_URL=$(terraform output -raw ecr_repository_url)
cd app && docker build -t app .
docker tag app:latest ${REPOSITORY_URL}:latest
docker tag app:latest ${REPOSITORY_URL}:${HASH}
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPOSITORY_URL}
docker push ${REPOSITORY_URL}:latest
docker push ${REPOSITORY_URL}:${HASH}
cd ..
terraform apply -auto-approve -var="moodle_skip_install=false"
CLUSTER_NAME=$(terraform output -raw cluster_name)
SERVICE_NAME=$(terraform output -raw service_name)
# check that first container deploys properly. If so, proceed with rest of deployment skipping database installations in future containers
while [ "$(aws ecs describe-services --cluster ${CLUSTER_NAME} --services ${SERVICE_NAME} --query 'services[0].deployments[?status==`PRIMARY`].runningCount' --output text)" != "1" ]; do \
	echo "Waiting for initial container to perform moodle installation..."; \
	sleep 10; \
done
echo "Container deployed successfully."

terraform apply -auto-approve -var="moodle_skip_install=true"