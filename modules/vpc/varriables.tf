variable "vpc_name" {
  type        = string
  description = "Name prefix for the VPC and related resources"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC (e.g., 172.40.0.0/16)"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Exactly three CIDR blocks for public subnets (A,B,C)"
  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "public_subnet_cidrs must contain exactly 3 CIDRs."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Exactly three CIDR blocks for private subnets (A,B,C)"
  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "private_subnet_cidrs must contain exactly 3 CIDRs."
  }
}

variable "azs" {
  type        = list(string)
  description = "Exactly three AZs (e.g., eu-west-2a,b,c)"
  validation {
    condition     = length(var.azs) == 3
    error_message = "azs must contain exactly 3 AZ names."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags applied to all resources"
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
  description = "Create NAT gateway and default route for private subnets"
}

variable "single_nat_gateway" {
  type    = bool
  default = true
  description = "Keep to one NAT GW (in public subnet A)"
}
