provider "aws" {
  #region = "us-east-1"
  alias = "us_east_1"
  default_tags {
    tags = {
      Terraformed     = "True"
    }
  }
}