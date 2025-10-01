# environments/test/apps/versions.tf
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.use1]
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
      Layer       = "Platform"
      ManagedBy   = "GitHub Actions + Terraform"
    }
  }
}

# # Alias for global services that live in us-east-1 (CloudFront, WAFv2[CLOUDFRONT], ACM for CF, etc.)
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "Test"
      Project     = "Kuflink"
      Layer       = "Platform"
      ManagedBy   = "GitHub Actions + Terraform"
    }
  }
}