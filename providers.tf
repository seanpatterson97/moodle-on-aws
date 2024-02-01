########################################################################################################################
# AWS provider setup
########################################################################################################################

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.33.0"
    }
    # Used to generate secure header credentials for communication between cloudfront and load balancer. 
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/restrict-access-to-load-balancer.html
    random = {
      source = "hashicorp/random"
      version = "3.6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias = "us_east_1"
  shared_credentials_files = ["/home/codespace/.aws/credentials"]

  default_tags {
    tags = {
      Terraformed     = "True"
    }
  }
}