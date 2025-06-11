terraform {

  required_providers {
    aws = { 
      source  = "hashicorp/aws"
      version = ">= 5.84.0"
    }
  }
}

provider "aws" {
  alias  = "eu-west-2" 
  region = "eu-west-2"
}

module "vpc-terraform" {
  source = "../../../modules/vpc-terraform"
  vpc_name                = "Kuflink-Test-VPC"
  vpc_cidr_block          = var.vpc_cidr_block
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway 
  enable_dns_hostnames    = var.enable_dns_hostnames 
  enable_dns_support      = var.enable_dns_support
}
