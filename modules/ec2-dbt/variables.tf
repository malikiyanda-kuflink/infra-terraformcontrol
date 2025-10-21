variable "private_subnet_id" { type = string }
variable "vpc_id" { type = string }
variable "dbt_instance_profile_name" { type = string }
variable "dbt_name" { type = string }
variable "instance_type" { type = string }
variable "ssh_key_name" { type = string }
variable "dbt_sg_id" { type = string }
variable "dbt_user_data" { type = string }
variable "canonical_id" { type = string }

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

