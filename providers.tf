########################################################################################################################
# AWS provider setup
########################################################################################################################

terraform {
  # If using terraform cloud 
  cloud {
    organization = ""
    workspaces {
      name = "" 
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.33.0"
    }
    # Provider used to generate secure header credentials for communication between cloudfront and load balancer. 
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/restrict-access-to-load-balancer.html
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
