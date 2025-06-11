variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "office_ip_cidr_blocks" {
  type    = list(string)
  default = []
}


variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway across AZs"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}
