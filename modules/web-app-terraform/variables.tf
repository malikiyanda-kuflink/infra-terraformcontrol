variable "eb_role_arn" {
  type = string
}

variable "eb_instance_profile_arn" {
  description = "Name for the Elasticbeanstalk Instance Profile"
  type        = string
}

variable "ssl_certificate_arn" {
  type        = string
  description = "ACM ARN for HTTPS listener"
}


variable "redis_elastic_cache_password" {
  description = "Auth token for Redis (must be 16–128 chars)"
  type        = string
}

variable "redis_endpoint" {
  description = "Redis Endpoint"
  type        = string
}

variable "redis_elastic_cache_php_client" {
  description = "Redis Client"
  type        = string
}


variable "redis_elastic_cache_port" {
  description = "Redis Port"
  type        = string
}






# Networking
variable "vpc_id" {
  type        = string
  description = "VPC ID for the application"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs"
}

# variable "elb_security_group_id" {
#   type        = string
#   description = "Security group ID for ELB"
# }

# variable "eb_ssh_sg_id" {
#   type        = string
#   description = "Security group ID for EB SSH access"
# }

# variable "ssl_certificate_arn" {
#   type        = string
#   description = "SSL Certificate ARN"
# }

# Secrets
# variable "db_test_username" {
#   type        = string
#   description = "Database username for test DB"
# }

# variable "db_test_password" {
#   type        = string
#   description = "Database password for test DB"
# }

# variable "db_test_host" {
#   type        = string
#   description = "Database host for test DB"
# }

# variable "redis_elastic_cache_password" {
#   type        = string
#   description = "Redis password for Elastic Cache"
# }

variable "mandrill_secret" {
  type        = string
  description = "Mandrill secret key"
}

variable "bank_of_england_api_url" {
  type        = string
  description = "Bank of England API URL"
}

# variable "app_key" {
#   type        = string
#   description = "Laravel application key"
# }

# App configuration


# variable "app_url" {
#   type        = string
#   description = "Application base URL"
# }

variable "environment" {
  type        = string
  description = "Deployment environment name"
}
