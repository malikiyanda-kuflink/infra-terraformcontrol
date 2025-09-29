module "vpc" {
source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/vpc?ref=v0.1.71"
  vpc_name             = local.vpc.name
  vpc_cidr_block       = local.vpc.cidr
  public_subnet_cidrs  = local.vpc.public_cidrs
  private_subnet_cidrs = local.vpc.private_cidrs
  azs                  = local.vpc.azs
  enable_nat_gateway   = local.vpc.enable_nat
  single_nat_gateway   = local.vpc.single_nat
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project = "Kuflink" # this will merge in addition to default_tag
  }
}