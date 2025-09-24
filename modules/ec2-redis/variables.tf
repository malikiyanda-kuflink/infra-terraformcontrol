variable "private_subnet_id" { type = string }
variable "vpc_id" { type = string }
variable "ssh_key_parameter_name" { type = string }
variable "redis_instance_profile_name" { type = string }
variable "redis_name" { type = string }
variable "instance_type" { type = string }
variable "ssh_key_name" { type = string }
variable "redis_sg_id" { type = string }
variable "redis_ami_id" { type = string }
variable "redis_user_data" { type = string }
variable "redis_user_data_replace_on_change" { type = string }
variable "associate_public_ip_address" { type = string }
variable "redis_host_param_name" { type = string }

