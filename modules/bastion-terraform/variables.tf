variable "public_subnet_id" {
  description = "Public subnet ID to deploy the Bastion host in"
  type        = string
}

# variable "vpc_name" {
#   type = string
# }

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "office_ip_cidr_blocks" {
  description = "Office CIDRs allowed to SSH into Bastion"
  type        = list(string)
}

variable "ssh_key_parameter_name" {
  description = "SSM Parameter name for SSH PEM key"
  type        = string
}

variable "bastion_name" {
  description = "Name to assign to Bastion instance and related resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Bastion host"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "SSH key name to use for Bastion instance"
  type        = string
}

