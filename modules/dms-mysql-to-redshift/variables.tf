variable "name_prefix" {
  type = string
}

variable "region" {}
variable "dms_dashboard_name" {}

# Replication Instance
variable "replication_instance_id" {}
variable "instance_class" {}
variable "allocated_storage" {}
variable "availability_zone" {}
variable "security_group_ids" { type = list(string) }

# Replication Task
variable "replication_task_id" {}
variable "full_load_replication_task_id" {}
variable "table_mappings_json" { type = string }
variable "replication_task_settings_json" { type = string }
variable "dms_access_for_endpoint_role_arn" { type = string }
variable "replication_subnet_group_id" { type = string }


# Source DB
variable "source_endpoint_id" {}
variable "source_db_user" {}
variable "source_db_password" {}
variable "source_db_host" {}
variable "source_db_port" {}
variable "source_db_name" {}

# Target DB (Redshift)
variable "target_endpoint_id" {}
variable "target_db_host" { default = " " }
variable "target_db_user" { default = " " }
variable "target_db_password" { default = " " }
variable "target_db_port" {}
variable "target_db_name" {}



