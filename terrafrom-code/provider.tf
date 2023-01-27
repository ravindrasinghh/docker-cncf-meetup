terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.29.0"
    }
  }
}
provider "aws" {
  region              = "us-west-2"
  allowed_account_ids = [PUT your ACC. No]
  default_tags {
    tags = {
      environment = "meetup-app"
      managedby   = "terraform"
    }
  }
}
