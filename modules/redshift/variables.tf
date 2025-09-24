variable "redshift_cluster_identifier_name" { type = string }
variable "redshift_node_type" { type = string }
variable "redshift_num_of_nodes" { type = number }
variable "redshift_database_name" { type = string }
variable "redshift_username" { type = string }
variable "redshift_password" { type = string }
variable "redshift_port" { type = number }
variable "redshift_subnet_group_name" { type = string }
variable "redshift_sg_id" { type = string }
variable "redshift_role_arn" { type = string }
variable "redshift_dms_role_arn" { type = string }
variable "redshift_parameter_group_name" { type = string }
variable "redshift_publicly_accessible" { type = bool }
variable "redshift_encrypted" { type = bool }
variable "redshift_skip_final_snapshot" { type = bool }
variable "redshift_daily_resume" {}
variable "redshift_daily_pause" {}

variable "dms_access_for_endpoint_arn" { type = string }   
