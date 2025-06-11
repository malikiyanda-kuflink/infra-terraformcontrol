variable "office_ip_cidr_blocks" {
  description = "Office CIDRs allowed to SSH into Bastion"
  type        = list(string)
}

variable "ssh_key_parameter_name" {
  description = "SSM Parameter name for SSH PEM key"
  type        = string
}

