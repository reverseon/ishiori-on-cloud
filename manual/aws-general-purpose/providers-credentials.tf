# This meant to be run manually and not setup in the CI. Thus, set the aws profile to the one that has access to the s3 bucket.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 1.12.0"
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "ishiori1gp" # please aws configure sso --profile ishiori1gp or aws sso login --profile ishiori1gp
}

data "aws_caller_identity" "current" {}

output "current_aws_caller_identity" {
  value = data.aws_caller_identity.current
}