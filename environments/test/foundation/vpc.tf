module "vpc" {
  source               = "../../../modules/vpc"
  vpc_name             = local.vpc.name
  vpc_cidr_block       = local.vpc.cidr
  public_subnet_cidrs  = local.vpc.public_cidrs
  private_subnet_cidrs = local.vpc.private_cidrs
  azs                  = local.vpc.azs
  enable_dns_hostnames = local.vpc.enable_dns_hostnames 
  enable_dns_support   = local.vpc.enable_dns_support

  tags = {
    Project = "Kuflink" # this will merge in addition to default_tag
  }
}