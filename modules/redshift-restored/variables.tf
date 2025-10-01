variable "redshift_cluster_identifier_name" { type = string }
variable "redshift_snapshot_identifier" { type = string }
variable "redshift_node_type" { type = string }
variable "redshift_port" { type = number }
variable "redshift_subnet_group_name" { type = string }
variable "redshift_sg_id" { type = string }
variable "redshift_role_arn" { type = string }
variable "redshift_dms_role_arn" { type = string }
variable "redshift_skip_final_snapshot" { type = bool }
variable "redshift_database_name" { type = string }
variable "redshift_username" { type = string }
variable "redshift_publicly_accessible" { type = bool }
variable "redshift_encrypted" { type = bool }
variable "redshift_enhanced_vpc_routing" { type = bool }

variable "redshift_daily_resume" {}
variable "redshift_daily_pause" {}

# variable "redshift_num_of_nodes" { type = number }
# variable "kms_key_id"            { type = string }

variable "dms_access_for_endpoint_arn" { type = string }
