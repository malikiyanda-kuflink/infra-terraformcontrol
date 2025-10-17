variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID to deploy EC2 instance in (should be private subnet)"
  type        = string
}

variable "bastion_sg_id" {
  description = "Bastion Security Group ID allowed to SSH into this instance"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key name to use for instance"
  type        = string
}

variable "instance_name" {
  description = "Name to assign to this EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "test_instance_sg_id" {
  description = "Test Instance SG ID"
  type        = string
}

