# Makefile to wrap terraform commands

plan:
	terraform plan -var="first_deploy=false"

# Used to create a fresh repo, deploy the initial container, perform necessary database setup for moodle, then update the service to skip insatall for future containers
first-deploy: 
	sh ./first-deploy.sh

apply:
	terraform apply -auto-approve -var="moodle_skip_install=true"

destroy:
	terraform destroy -auto-approve -var="moodle_skip_install=true"
