variable "backup_vault_name" {
  description = "Name of the backup vault"
  type        = string
}

variable "backup_plan_name" {
  description = "Name of the backup plan"
  type        = string
}

variable "backup_service_role_arn" {
  description = "ARN of IAM Role for AWS Backup service to perform backups"
  type        = string
}

variable "rds_instance_arn" {
  description = "ARN of the RDS instance to back up"
  type        = string
}

variable "ec2_instance_arn" {
  description = "ARN of the EC2 instance to back up"
  type        = string
}

variable "environment" {
  description = "Environment tag (test, prod, etc)"
  type        = string
}
