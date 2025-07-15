terraform {
  backend "s3" {
    bucket  = "ishiori-ci-terraform-state"
    key     = "cistate/cloudflare"
    region  = "ap-northeast-1"
    encrypt = true
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.5.0"
    }
  }
  required_version = ">= 1.12.0"
}


variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token" # set using TF_VAR_cloudflare_api_token
  sensitive   = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}