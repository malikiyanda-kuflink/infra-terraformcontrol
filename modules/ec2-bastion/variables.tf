variable "public_subnet_id" { type = string }
variable "vpc_id" { type = string }
variable "bastion_instance_profile_name" { type = string }
variable "bastion_name" { type = string }
variable "instance_type" { type = string }
variable "ssh_key_name" { type = string }
variable "bastion_sg_id" { type = string }
variable "bastion_ami_id" { type = string }
variable "bastion_elastic_ip_name" { type = string }
variable "bastion_user_data" { type = string }
variable "instance_tags" {}

