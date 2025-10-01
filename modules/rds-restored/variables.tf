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
  description = "RDS security group ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group"
  type        = list(string)
}

# variable "restore_rds_from_snapshot" {
#   description = "Restore the snapshot module control"
#   type        = string  
# }

variable "db_snapshot_identifier" {
  description = "Snapshot identifier/ARN to restore from (required for restored module)"
  type        = string
}

variable "db_name_identifier" {
  description = "DB instance identifier"
  type        = string
}

variable "db_username" {
  description = "DB master username"
  type        = string
}

# variable "backup_retention_period" {
#   description = "Number of days to retain backups"
#   type        = number
# }


variable "db_password" {
  description = "DB master password"
  type        = string
  sensitive   = true
}

variable "instance_class" { type = string }
variable "storage_encrypted" { type = bool }
variable "publicly_accessible" { type = bool }


# # Engine / sizing
# variable "engine"         { type = string }
# variable "engine_version" { type = string }
variable "allocated_storage" { type = number }
# variable "storage_type"      { type = string } # gp2/gp3/etc.
# variable "multi_az"          { type = bool }
# # Ops / safety
# variable "backup_retention_period"    { type = number }
variable "skip_final_snapshot" { type = bool }
# variable "auto_minor_version_upgrade" { type = bool }
variable "deletion_protection" { type = bool }
# variable "iam_database_authentication_enabled" { type = bool }

# Read replica
variable "create_read_replica" {
  description = "Create a read replica"
  type        = bool
  default     = false
}

variable "replica_instance_class" {
  description = "Read replica instance class"
  type        = string
  default     = "db.t3.small"
}

# Optional: override MySQL params (name => value)
variable "mysql_parameters" {
  description = "Optional map of MySQL parameter overrides"
  type        = map(string)
  default = {
    log_bin_trust_function_creators = "1"
    binlog_format                   = "ROW"
    binlog_row_image                = "FULL"
    wait_timeout                    = "28800"
    interactive_timeout             = "28800"
    net_read_timeout                = "600"
    net_write_timeout               = "600"
  }
}

variable "backup_retention_period" {
  type    = number
  default = 7
}


variable "name_prefix_upper" {
  type = string
}

# ===== NEW STORAGE VARIABLES =====

variable "max_allocated_storage" {
  description = "Maximum allocated storage for auto-scaling in GiB (0 to disable auto-scaling)"
  type        = number
  default     = 0
}

variable "storage_type" {
  description = "Storage type - gp2, gp3, io1, io2"
  type        = string
  default     = "io1"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, io2."
  }
}

variable "iops" {
  description = "Provisioned IOPS for io1/io2 storage types (required for io1/io2)"
  type        = number
  default     = 1000
  validation {
    condition     = var.iops >= 100 && var.iops <= 80000
    error_message = "IOPS must be between 100 and 80000."
  }
}

variable "storage_throughput" {
  description = "Storage throughput for gp3 storage type (MB/s)"
  type        = number
  default     = null
}

# ===== REPLICA STORAGE VARIABLES =====
variable "replica_allocated_storage" {
  description = "Replica initial allocated storage in GiB (null to inherit from primary)"
  type        = number
  default     = null
}

variable "replica_max_allocated_storage" {
  description = "Replica maximum allocated storage for auto-scaling in GiB (null to inherit)"
  type        = number
  default     = null
}

variable "replica_iops" {
  description = "Replica provisioned IOPS (null to inherit from primary)"
  type        = number
  default     = null
}

variable "replica_storage_type" {
  description = "Replica storage type (null to inherit from primary)"
  type        = string
  default     = null
}

# ===== DATABASE INSIGHTS VARIABLES =====
variable "performance_insights_enabled" {
  description = "Enable Performance Insights for enhanced database monitoring"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days (7 for free tier, 731 for paid)"
  type        = number
  default     = 7
  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be either 7 (free) or 731 days (paid)."
  }
}

variable "performance_insights_kms_key_id" {
  description = "KMS key ID for Performance Insights encryption (optional)"
  type        = string
  default     = null
}

variable "create_performance_insights_kms_key" {
  description = "Create a dedicated KMS key for Performance Insights"
  type        = bool
  default     = false
}

# ===== ENHANCED MONITORING VARIABLES =====
variable "monitoring_role_arn" { type = string }

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 60
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60 seconds."
  }
}

# ===== CLOUDWATCH LOGS VARIABLES =====
variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch - depends on database engine"
  type        = list(string)
  default     = ["error", "general", "slowquery"]
  validation {
    condition = alltrue([
      for log_type in var.enabled_cloudwatch_logs_exports :
      contains([
        "agent", "alert", "audit", "diag.log", "error", "general",
        "iam-db-auth-error", "listener", "notify.log", "oemagent",
        "postgresql", "slowquery", "trace", "upgrade"
      ], log_type)
    ])
    error_message = "Invalid log export type. Valid options depend on database engine."
  }
}