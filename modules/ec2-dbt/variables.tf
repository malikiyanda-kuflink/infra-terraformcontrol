variable "private_subnet_id" { type = string }
variable "vpc_id" { type = string }
variable "dbt_instance_profile_name" { type = string }
variable "dbt_name" { type = string }
variable "instance_type" { type = string }
variable "ssh_key_name" { type = string }
variable "dbt_user_data" { type = string }
variable "canonical_id" { type = string }
variable "alb_sg_id" { type = string }
variable "dbt_sg_id" { type = string }
variable "instance_tags" {}



variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for ALB (must be in at least 2 AZs)"
}

variable "acm_certificate_arn" {
  type = string
}

variable "dbt_docs_subdomain" {
  type        = string
  description = "Subdomain for dbt docs (e.g., dbt-staging.brickfin.co.uk)"
}


# variable "dbt_elastic_ip_name" { type = string }

# ============================================================================
# Variables for CodeDeploy Configuration
# ============================================================================



variable "code_deploy_project_name" {
  description = "Name of your project (used for resource naming)"
  type        = string
}

variable "name_prefix" { type = string }
variable "environment" { type = string }

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy Service Role ARN"
  type        = string
}

variable "notification_email" {
  description = "Email address for CodeDeploy notifications (leave empty to disable)"
  type        = string
  default     = "" # Set to your email: "you@example.com"
}


