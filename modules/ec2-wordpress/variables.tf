variable "aws_route53_zone" {
  type = string
}
variable "vpc_id" {
  description = "VPC ID for the security group"
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

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "TeamLeadPublicKey" {
  description = "Team Lead Public Key for EC2 Access"
}

variable "DevOpsPublicKey" {
  description = "DevOps Public Key for EC2 Access"
}

variable "DevOpsKeyPair" {
  description = "Devops key pair"
}

variable "StagingsKeyPair" {
  description = "Staging key pair"
}

variable "DefaultAMI_ID" {
  description = "Ubuntu AMI"
}

variable "DefaultInstanceType" {
  description = "Instance Type "
}

variable "office_ip" {
  type = string
}

variable "bastion_ip" {
  type = string
}

variable "ssl_cert" {
  type = string
}

variable "kuflink_wp_sg_id" {
  type = string
}
