# ========================================
# Network Configuration
# ========================================
variable "private_subnet_id" {
  type        = string
  description = "Private subnet ID for DBT instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ALB (must be in at least 2 AZs)"
}

# ========================================
# Instance Configuration
# ========================================
variable "dbt_name" {
  type        = string
  description = "Name of the DBT instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "dbt_user_data" {
  type        = string
  description = "User data script for instance initialization"
}

variable "canonical_id" {
  type        = string
  description = "Canonical AWS account ID for Ubuntu AMIs"
}

variable "instance_tags" {
  description = "Additional tags for the instance"
}

# ========================================
# IAM Configuration
# ========================================
variable "dbt_instance_profile_name" {
  type        = string
  description = "IAM instance profile name"
}

# ========================================
# Security Configuration
# ========================================
variable "alb_sg_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "dbt_sg_id" {
  type        = string
  description = "Security group ID for DBT instance"
}

# ========================================
# Root Block Device Configuration
# ========================================
variable "root_volume_type" {
  description = "Type of root volume (gp3, gp2, io1, io2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "gp2", "io1", "io2"], var.root_volume_type)
    error_message = "Root volume type must be one of: gp3, gp2, io1, io2"
  }
}

variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 GB and 16384 GB"
  }
}

variable "root_volume_iops" {
  description = "IOPS for root volume (only applies to gp3, io1, io2)"
  type        = number
  default     = 3000

  validation {
    condition     = var.root_volume_iops >= 3000 && var.root_volume_iops <= 16000
    error_message = "Root volume IOPS must be between 3000 and 16000 for gp3"
  }
}

variable "root_volume_throughput" {
  description = "Throughput in MB/s for root volume (only applies to gp3)"
  type        = number
  default     = 125

  validation {
    condition     = var.root_volume_throughput >= 125 && var.root_volume_throughput <= 1000
    error_message = "Root volume throughput must be between 125 MB/s and 1000 MB/s for gp3"
  }
}

variable "root_volume_encrypted" {
  description = "Enable encryption for root volume"
  type        = bool
  default     = true
}

variable "root_volume_kms_key_id" {
  description = "KMS key ID for root volume encryption (optional, uses AWS managed key if not specified)"
  type        = string
  default     = null
}

variable "root_volume_delete_on_termination" {
  description = "Delete root volume when instance is terminated"
  type        = bool
  default     = true
}

# ========================================
# DNS & Certificate Configuration
# ========================================
variable "route53_zone_name" {
  type        = string
  description = "Route53 hosted zone name"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS"
}

variable "dbt_docs_subdomain" {
  type        = string
  description = "Subdomain for dbt docs"
}

# ========================================
# Monitoring & Notifications
# ========================================
variable "cloudwatch_ops_notification_email" {
  type        = string
  description = "Email address for CloudWatch operational notifications"
}

variable "notification_email" {
  description = "Email address for CodeDeploy notifications (leave empty to disable)"
  type        = string
  default     = ""
}

# ========================================
# CodeDeploy Configuration
# ========================================
variable "code_deploy_project_name" {
  description = "Name of your project (used for resource naming)"
  type        = string
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (test, staging, production)"
}

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy Service Role ARN"
  type        = string
}

# ========================================
# Commented Out Variables
# ========================================
# variable "dbt_elastic_ip_name" { type = string }