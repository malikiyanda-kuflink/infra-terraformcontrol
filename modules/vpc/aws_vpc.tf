resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = merge(var.tags, { Name = var.vpc_name })
}

# Public subnets
resource "aws_subnet" "public" {
  for_each = {
    a = { cidr = var.public_subnet_cidrs[0], az = var.azs[0] }
    b = { cidr = var.public_subnet_cidrs[1], az = var.azs[1] }
    c = { cidr = var.public_subnet_cidrs[2], az = var.azs[2] }
  }
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.vpc_name}-public-${each.key}" })
}

# Private subnets
resource "aws_subnet" "private" {
  for_each = {
    a = { cidr = var.private_subnet_cidrs[0], az = var.azs[0] }
    b = { cidr = var.private_subnet_cidrs[1], az = var.azs[1] }
    c = { cidr = var.private_subnet_cidrs[2], az = var.azs[2] }
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge(var.tags, { Name = "${var.vpc_name}-private-${each.key}" })
}
