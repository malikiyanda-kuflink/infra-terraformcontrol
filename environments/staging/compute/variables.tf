variable "office_ip_cidr_blocks" {
  description = "Office CIDRs allowed to SSH into Bastion"
  type        = list(string)
}

variable "ssh_key_parameter_name" {
  description = "SSM Parameter name for SSH PEM key"
  type        = string
}

variable "environment" {
  type = string 
}
variable "ssl_certificate_arn" {
  type        = string
  description = "ACM ARN for HTTPS listener"
}


variable "redis_elastic_cache_password" {
  type        = string
  description = "Password for Redis authentication"
}

