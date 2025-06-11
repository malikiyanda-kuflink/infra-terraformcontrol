# variable "bastion_sg_id" {
#   type = string
# }

variable "vpc_name" {
  type = string
}

variable "office_ip_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
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
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}
