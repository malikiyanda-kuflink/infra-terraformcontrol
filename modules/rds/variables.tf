variable "name_prefix" {
  description = "Prefix for named resources (e.g., kuflink-<env>)"
  type        = string
}

variable "tags" {
  description = "Extra tags to apply to all resources"
  type        = map(string)
  default     = {}
}
variable "db_parameter_group_name" {
  description = "db parameter group name "
  type        = string
}
variable "db_subnet_group_name" {
  description = "db subnet group name "
  type        = string
}

variable "rds_sg_id" {
  description = "RDS Security Group ID"
  type        = string
}

# variable "rds_name_tag" {
#   description = "Name tag to use for RDS resources"
#   type        = string
# }

# variable "restore_rds_from_snapshot" {
#   description = "Whether to restore from snapshot"
#   type        = bool
# }

# Existing variables for Secrets Manager outputs

variable "db_username" {
  description = "DB username"
  type        = string
}

variable "db_password" {
  description = "DB password"
  type        = string
}

variable "db_database" {
  description = "DB name"
  type        = string
}

variable "db_name_identifier" {
  description = "DB instance identifier"
  type        = string
}

variable "db_snapshot_identifier" {
  type    = string
  default = ""
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
  description = "Instance class"
  type        = string
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

variable "create_read_replica" {
  description = "Whether to create a read replica of the restored instance"
  type        = bool
}

variable "replica_instance_class" {
  description = "Read Replcia Instance class (e.g. db.t3.small)"
  type        = string
}

variable "backup_retention_period" {
  type    = number
  default = 7
}






