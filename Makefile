# Makefile to wrap terraform commands

plan:
	terraform plan -var="moodle_skip_install=true"

first-deploy: 
	sh ./first-deploy.sh

apply:
	terraform apply -auto-approve -var="moodle_skip_install=true"

destroy:
	terraform destroy -auto-approve -var="moodle_skip_install=true"
