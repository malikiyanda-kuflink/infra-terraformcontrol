# variable "vpc_id" {
#   description = "The VPC ID to deploy RDS and security group into"
#   type        = string
# }

# variable "private_subnet_ids" {
#   description = "List of private subnet IDs for RDS subnet group"
#   type        = list(string)
# }


variable "db_parameter_group_name" {
  description = "RDS Parameter group to use"
  type        = string
}

variable "rds_sg_id" {
  description = "RDS Security Group ID"
  type        = string
}

variable "db_subnet_group_name" {
  description = "RDS DB Subnet Group name"
  type        = string
}
variable "rds_name_tag" {
  description = "Name tag to use for RDS resources"
  type        = string
}

# variable "rds_allowed_cidr_blocks" {
#   description = "CIDRs allowed to access RDS (SG rule)"
#   type        = list(string)
# }

variable "environment" {
  description = "Environment tag to apply (staging/prod)"
  type        = string
}

variable "restore_from_snapshot" {
  description = "Whether to restore from snapshot"
  type        = bool
}

# Existing variables for Secrets Manager outputs

variable "db_test_username" {
  description = "DB username"
  type        = string
}

variable "db_test_password" {
  description = "DB password"
  type        = string
}

variable "db_test_database" {
  type    = string
  default = ""
}


variable "db_test_name_identifier" {
  description = "DB instance identifier"
  type        = string
}

variable "db_test_snapshot_identifier" {
  description = "Snapshot identifier to restore from"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage size (in GB)"
  type        = number
}

variable "storage_type" {
  description = "Storage type (e.g. gp2, gp3)"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g. mysql, postgres)"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class (e.g. db.t3.medium)"
  type        = string
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot on destroy"
  type        = bool
}

variable "auto_minor_version_upgrade" {
  description = "Whether to enable auto minor version upgrades"
  type        = bool
}

variable "publicly_accessible" {
  description = "Whether the DB is publicly accessible"
  type        = bool
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection"
  type        = bool
}

variable "multi_az" {
  description = "Whether to deploy Multi-AZ"
  type        = bool
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM authentication"
  type        = bool
}

variable "storage_encrypted" {
  description = "Whether to encrypt storage"
  type        = bool
}

