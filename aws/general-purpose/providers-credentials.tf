terraform {
  backend "s3" {
    bucket  = "ishiori-ci-terraform-state"
    key     = "cistate/aws"
    region  = "ap-northeast-1"
    encrypt = true
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 1.12.0"
}

# Default provider for ap-northeast-1
provider "aws" {
  region = "ap-northeast-1"
}

# Provider for us-east-1 (required for public ECR)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

output "current_aws_caller_identity" {
  value = {
    account_id          = data.aws_caller_identity.current.id
    arn_without_session = replace(data.aws_caller_identity.current.arn, "/\\/[a-f0-9]{40}$/", "")
  }
}