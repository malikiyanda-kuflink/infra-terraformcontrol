# environments/test/apps/versions.tf
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"            
    }
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region for this stack"
  default     = "eu-west-2"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "Test"
      Project     = "Kuflink"
      Layer       = "Data"
      ManagedBy   = "GitHub Actions + Terraform"
    }
  }
}
