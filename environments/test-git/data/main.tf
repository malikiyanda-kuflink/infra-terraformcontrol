# RDS Deprecated Instance
variable "blue_db_identifier" {
  description = "Legacy BLUE primary DB identifier (leave empty if none)."
  type        = string
  default     = "kuflink-staging"
}

variable "blue_db_ro_identifier" {
  description = "Legacy BLUE read-only DB identifier (leave empty if none)."
  type        = string
  default     = "kuflink-staging-replica"
}

data "aws_db_instance" "rds_legacy" {
  count                  = length(var.blue_db_identifier) > 0 ? 1 : 0
  db_instance_identifier = var.blue_db_identifier
}

data "aws_db_instance" "rds_ro_legacy" {
  count                  = length(var.blue_db_ro_identifier) > 0 ? 1 : 0
  db_instance_identifier = var.blue_db_ro_identifier
}

# # RDS Module - new DB create
module "rds" {
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/rds?ref=v0.1.0"
  count  = local.restore_rds_from_snapshot ? 0 : 1

  name_prefix        = local.name_prefix
  db_name_identifier = local.new_primary_rds_instance_identifier
  tags               = { Project = "Kuflink" } 

  rds_sg_id   = aws_security_group.rds_sg.id
  db_username = data.terraform_remote_state.foundation.outputs.db_username
  db_password = data.terraform_remote_state.foundation.outputs.db_password
  db_database = data.terraform_remote_state.foundation.outputs.db_database


  db_parameter_group_name = aws_db_parameter_group.kuflink_parameter_group.name
  db_subnet_group_name    = aws_db_subnet_group.kuflink_db_subnet_group.name
  

  allocated_storage                   = 100
  backup_retention_period             = 7
  storage_type                        = "gp2"
  engine                              = "mysql"
  engine_version                      = "8.0.40"
  instance_class                      = "db.t3.medium"
  auto_minor_version_upgrade          = true
  storage_encrypted                   = true
  skip_final_snapshot                 = true
  publicly_accessible                 = false
  deletion_protection                 = false
  multi_az                            = false
  iam_database_authentication_enabled = false

  create_read_replica    = local.create_read_replica
  replica_instance_class = "db.t3.small" 

}

# RDS Restore Module - restore from snapshot
module "rds_restore" {
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/rds-restored?ref=v0.1.63"
  # If restoring from snapshot → true, else false for new instance
  # restore_rds_from_snapshot = local.restore_rds_from_snapshot 
  count = local.restore_rds_from_snapshot ? 1 : 0 

  # Naming & tags
  name_prefix = local.name_prefix 
  name_prefix_upper = local.name_prefix_upper 
  tags        = { Project = "Kuflink" }

  # Database Insights settings
  monitoring_role_arn = data.terraform_remote_state.foundation.outputs.rds_enhanced_monitoring_role_arn
  performance_insights_enabled = true
  monitoring_interval = 60  # Enhanced monitoring every 60 seconds
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]  # MySQL logs

  #RDS Components 
  db_parameter_group_name = aws_db_parameter_group.kuflink_parameter_group.name 
  db_subnet_group_name    = aws_db_subnet_group.kuflink_db_subnet_group.name

  # Networking
  private_subnet_ids = data.terraform_remote_state.foundation.outputs.private_subnet_ids
  rds_sg_id          = aws_security_group.rds_sg.id

  # Restore inputs
  db_snapshot_identifier = local.db_snapshot_identifier
  db_name_identifier     = local.restored_primary_rds_instance_identifier
  db_username            = data.terraform_remote_state.foundation.outputs.db_username
  db_password            = data.terraform_remote_state.foundation.outputs.db_password

  storage_encrypted   = false
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false
  # instance_class      = "db.t3.medium"
  instance_class      = "db.t3.xlarge"
  allocated_storage   = 100


  # Read replica
  create_read_replica    = local.create_read_replica
  replica_instance_class = "db.t3.small"



}

# Redshift Module
module "redshift" {
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/redshift?ref=v0.1.0"
  count                            = local.enable_redshift && !local.restore_redshift_from_snapshot ? 1 : 0
  redshift_cluster_identifier_name = local.new_primary_redshift_cluster_identifier

  redshift_node_type           = "ra3.large"
  redshift_num_of_nodes        = 1
  redshift_encrypted           = true 
  redshift_skip_final_snapshot = true
  redshift_publicly_accessible = false

  redshift_daily_pause        = "${local.env}-redshiftdaily-pause"
  redshift_daily_resume       = "${local.env}-redshiftdaily-resume"
  redshift_dms_role_arn       = data.terraform_remote_state.foundation.outputs.redshift_dms_role_arn
  redshift_role_arn           = data.terraform_remote_state.foundation.outputs.redshift_role_arn
  dms_access_for_endpoint_arn = data.terraform_remote_state.foundation.outputs.staging_dms_endpoint_access_arn 

  redshift_sg_id                = aws_security_group.redshift_access.id
  redshift_subnet_group_name    = aws_redshift_subnet_group.kuflink_redshift_subnet_group.name
  redshift_parameter_group_name = aws_redshift_parameter_group.kuflink_redshift_pg.name

  redshift_database_name = data.terraform_remote_state.foundation.outputs.redshift_database_name
  redshift_username      = data.terraform_remote_state.foundation.outputs.redshift_username
  redshift_password      = data.terraform_remote_state.foundation.outputs.redshift_password
  redshift_port          = data.terraform_remote_state.foundation.outputs.redshift_port
}


module "redshift_restore" {
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/redshift-restored?ref=v0.1.0"
  count = local.enable_redshift && local.restore_redshift_from_snapshot ? 1 : 0
  redshift_cluster_identifier_name = local.restored_redshift_cluster_identifier
  redshift_snapshot_identifier     = local.redshift_snapshot_identifier

  redshift_node_type            = "ra3.large" 
  redshift_publicly_accessible  = false
  redshift_skip_final_snapshot  = true
  redshift_encrypted            = false 
  redshift_enhanced_vpc_routing = true


  redshift_daily_pause  = "${local.env}-redshiftdaily-pause"
  redshift_daily_resume = "${local.env}-redshiftdaily-resume"
  redshift_dms_role_arn = data.terraform_remote_state.foundation.outputs.redshift_dms_role_arn
  redshift_role_arn     = data.terraform_remote_state.foundation.outputs.redshift_role_arn
  dms_access_for_endpoint_arn = data.terraform_remote_state.foundation.outputs.staging_dms_endpoint_access_arn


  redshift_sg_id             = aws_security_group.redshift_access.id
  redshift_subnet_group_name = aws_redshift_subnet_group.kuflink_redshift_subnet_group.name

  redshift_database_name = data.terraform_remote_state.foundation.outputs.redshift_database_name
  redshift_username      = data.terraform_remote_state.foundation.outputs.redshift_username
  redshift_port          = data.terraform_remote_state.foundation.outputs.redshift_port
}

# # DMS mysql(secure)_to_redshift
module "dms_mysql_to_redshift" {
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/dms-mysql-to-redshift?ref=v0.1.0"
  count  = local.enable_redshift ? 1 : 0

  name_prefix                    = local.name_prefix
  region                         = "eu-west-2"
  dms_dashboard_name             = "Kuflink-${local.env}-Redshift-Sync-DMS-Dashboard"
  replication_instance_id        = "dms-${local.env}-redshift-sync"
  instance_class                 = "dms.t3.small"
  allocated_storage              = 50
  availability_zone              = "eu-west-2a"
  replication_subnet_group_id    = aws_dms_replication_subnet_group.dms_subnet_group[0].id
  security_group_ids             = [aws_security_group.dms_vpc_sg.id]
  table_mappings_json            = file("${path.root}/dms_config/table-mappings.json")
  replication_task_settings_json = file("${path.root}/dms_config/task-settings.json")

  # ---------- SOURCE (RDS) ----------
  # If green is active and you create a replica → use green RO records
  # else fall back to the green primary; for blue we always use the primary.
  source_endpoint_id = "${local.env}-rds-slave-source"
  source_db_user     = data.terraform_remote_state.foundation.outputs.db_username
  source_db_password = data.terraform_remote_state.foundation.outputs.db_password
  source_db_host = trim(
    lower(local.active_color) == "green"
    ? (local.create_read_replica
      ? aws_route53_record.live_mysql_ro[0].fqdn
      : aws_route53_record.live_mysql.fqdn
    )
    : aws_route53_record.blue_mysql[0].fqdn, ##############cehck this ...
    "."
  )
  source_db_name = data.terraform_remote_state.foundation.outputs.db_database
  source_db_port = "3306"
  target_db_port = "5439"

  # ---------- TARGET (Redshift) ----------
  target_endpoint_id = "${local.env}-redshift-target"
  target_db_user     = data.terraform_remote_state.foundation.outputs.redshift_username 
  target_db_password = data.terraform_remote_state.foundation.outputs.redshift_password
  target_db_name     = data.terraform_remote_state.foundation.outputs.redshift_database_name

  # target_db_host = trimsuffix(aws_route53_record.live_redshift[0].fqdn, ".")  #“cluster region is co and the current region is eu-west-2.”

  target_db_host = local.enable_redshift ? (local.restore_redshift_from_snapshot
    ? replace(module.redshift_restore[0].redshift_endpoint_address, "/:[0-9]+$/", "")
  : replace(module.redshift[0].redshift_endpoint_address, "/:[0-9]+$/", "")) : ""

  replication_task_id              = "${local.env}-mysql-to-redshift-cdc-sync"
  full_load_replication_task_id    = "${local.env}-mysql-to-redshift-full-load-sync"
  dms_access_for_endpoint_role_arn = data.terraform_remote_state.foundation.outputs.staging_dms_endpoint_access_arn

}

