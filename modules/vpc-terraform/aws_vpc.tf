resource "aws_vpc" "test_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.public_subnet_cidrs[2]
  availability_zone = "eu-west-2c"

  tags = {
    Name = "public-subnet-c"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.private_subnet_cidrs[2]
  availability_zone = "eu-west-2c"

  tags = {
    Name = "private-subnet-c"
  }
}
