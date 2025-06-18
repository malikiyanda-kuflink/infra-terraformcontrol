variable "private_subnet_ids" {
  description = "Private subnet IDs for ElastiCache"
  type        = list(string)
}

# variable "redis_sg_id" {
#   description = "Security Group ID for Redis"
#   type        = string
# }

variable "redis_elastic_cache_password" {
  description = "Auth token for Redis (must be 16–128 chars)"
  type        = string
}


variable "redis_elastic_cache_port" {
  description = "Redis Port"
  type        = string
}


variable "redis_cluster_id" {
  description = "ID for the Redis replication group"
  type        = string
  default     = "kuflink-test-redis-cluster"
}

variable "node_type" {
  description = "Node type for Redis"
  type        = string
  default     = "cache.t2.micro"
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "bastion_sg_id" {
  type        = string
  description = "Security Group ID of the Bastion host"
}

variable "web_app_sg_id" {
  type        = string
  description = "Security Group ID of the Elastic Beanstalk web app"
}

