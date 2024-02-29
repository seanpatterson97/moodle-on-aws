# Moodle-On-Aws

This repository contains demo code for a terraform deployment of [Moodle LMS](https://moodle.org/) on ECS Fargate using [Bitnami's Moodle container for docker](https://bitnami.com/stack/moodle). Although this repository contains components specifically for a deployment of Moodle, this template can be easily modified for alternate container-based projects using similar infrastructure. 

I used public templates as a boilerplate for this project and I am crediting each of my sources under the [Acknowledgments](#acknowledgements) section. 

### Summary

This project will deploy the following infrastructure:

![Cloud Architecture](https://github.com/seanpatterson97/moodle-on-aws/assets/60835724/fe02b8da-3ade-437e-942f-33e337b0312d)

Containers are deployed across availability zones in a private subnet, each with EFS access to serve as a central filesystem for the 'moodledata' directory which is responsible for course data. A RDS instance running MariaDB is created with access to the private subnet group. Tasks within the private subnet can connect to external services through the NAT gateway. External services can only connect to the service through CloudFront. 

CloudFront is configured to redirect all incoming http connections to https before passing traffic to the application load balancer. The ALB is configured to only accept encrypted connections with a unique custom header generated during the deployment of CloudFront. Accepted connections will be passed off to the containers. 

By default, a subdomain of dev.{servicename}.your-domain-name.com is created in Route53 and attached to CloudFront. Certificates are generated in ACM for both CloudFront and the application load balancer.

### Dependencies
  * Docker
  * Terraform
  * AWS CLI
  * A top level domain in Route53 for the project to reside on
  * IAM user with the permissions indicated within the [permissions.json](permissions.json) file

### Getting Started

DISCLAIMER: Because it's a demo, this project has been set up with minimal computational and storage settings by default. You will incur a small cost for the time this project is running. Destroy all infrastructure afterwards using the ```make destroy``` command to avoid unnecessary costs.

Begin by cloning the repo and navigating to it.

```
git clone https://github.com/seanpatterson97/moodle-on-aws/ && cd moodle-on-aws
```

Configure AWS credentials for the IAM user your program will be running as. Ensure the account has the proper credentials to run the project.

```
aws configure
```

For secret management I use Terraform Cloud, but you may replace this step with your preferred method of managing secrets. 

```
terraform login
```

Configure the account with your AWS credentials for the IAM user in use. 
![Screenshot 2024-02-02 104644](https://github.com/seanpatterson97/moodle-on-aws/assets/60835724/bab54934-2c96-4d49-8b18-bac51955793b)

Lastly, we will configure our tfvars. Terraform.auto.tfvars.example contains placeholders for the variables that you may wish to set. Additionally, it stipulates which variables are mandatory. 

```
cp terraform.auto.tfvars.example terraform.auto.tfvars
```

After these steps, you may begin to provision the project's infrastructure. Run the initial startup script from within the project directory.
```
make first-deploy
```

This command will perform the following steps:
* First, an ECR repository will be created to store docker images of the application within the app directory
* A time/date value will be generated to tag the image with
* Docker builds and publishes the image to ECR
* Terraform applies the target infrastructure
* Terraform detects if the container was successfully deployed in ecs, then reapplies the configuration with a flag to prevent installation scripts from running for subsequent containers

Typically, it takes 15 minutes for this command to deploy. Afterwards the service should be accessible on the subdomain you have created. By default it will be dev.{servicename}.your-domain-name.com

After you are finished with the demo you may run ```make destroy``` to delete the infrastructure to avoid incurring costs.

### Acknowledgements
[Aws-scenario-ecs-fargate ](https://github.com/nexgeneerz/aws-scenario-ecs-fargate)
This project contains a fantastic [blog post](https://nexgeneerz.io/how-to-setup-amazon-ecs-fargate-terraform/) which details the basics of a modern production-ready solution on fargate. I used it as a starting point for the project.

[Modernize Moodle LMS with AWS serverless containers](https://aws.amazon.com/blogs/publicsector/modernize-moodle-lms-aws-serverless-containers/)
Another great resource used to gain insight into some of the moodle-specific requirements for designing the project's architecture. 

### Limitations
* Bitnami moodle has an env variable flag ```MOODLE_SKIP_INSTALL``` which needs to be set to false to run its initial installation and provision the empty database. This value needs to be set to true for subsequent containers to prevent them from failing their install and exiting due to the database tables already existing. 
	* To avoid manual intervention each time the demo is launched, a value is passed in each terraform command in the Makefile to handle skip the installation process unless it is for the first deployment.
	* Upon initial deployment, if multiple containers are launched, only one container will succeed in starting up until terraform passes the update to skip the installation.  

### Future Implementations 
* Incorporate ElastiCache for Redis
* Create a more elegant solution to handle ```MOODLE_SKIP_INSTALL```
