terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}
provider "aws" {
  region = "ap-southeast-1"

  # Tags to apply to all AWS resources by default
  default_tags {
    tags = {
      Owner = "DevOps-Team"
      ManagedBy = "Terraform"
    }
  }
} 