# DMS Instance in the Kuflink VPC
# Performs DMS migration from MYSQL (RDS SECURE) -> MYSQL(REDSHIFT)
resource "aws_dms_replication_instance" "redshift_dms_instance" {
  replication_instance_id     = var.replication_instance_id
  replication_instance_class  = var.instance_class
  allocated_storage           = var.allocated_storage
  replication_subnet_group_id = var.replication_subnet_group_id
  availability_zone           = var.availability_zone
  vpc_security_group_ids      = var.security_group_ids
  publicly_accessible         = false
  auto_minor_version_upgrade  = true
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = var.source_endpoint_id
  endpoint_type = "source"
  engine_name   = "mysql"
  username      = var.source_db_user
  password      = var.source_db_password
  server_name   = var.source_db_host
  port          = var.source_db_port
  database_name = var.source_db_name
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = var.target_endpoint_id
  endpoint_type = "target"
  engine_name   = "redshift"
  username      = var.target_db_user
  password      = var.target_db_password
  server_name   = var.target_db_host
  port          = var.target_db_port
  database_name = var.target_db_name
  ssl_mode      = "none"
  redshift_settings {
    bucket_name             = aws_s3_bucket.dms_assessment_results.bucket
    bucket_folder           = "dms"
    service_access_role_arn = var.dms_access_for_endpoint_role_arn
  }
  extra_connection_attributes = "initstmt=SET FOREIGN_KEY_CHECKS=0"
}

resource "aws_dms_replication_task" "redshift_dms_task" {
  replication_task_id       = var.replication_task_id
  migration_type            = "full-load-and-cdc"
  replication_instance_arn  = aws_dms_replication_instance.redshift_dms_instance.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  table_mappings            = var.table_mappings_json
  replication_task_settings = var.replication_task_settings_json
  start_replication_task    = false # Important: prevent auto start
  lifecycle {
    ignore_changes = [replication_task_settings]
  }
}

resource "aws_dms_replication_task" "redshift_dms_task_full_load" {
  replication_task_id       = var.full_load_replication_task_id
  migration_type            = "full-load"
  replication_instance_arn  = aws_dms_replication_instance.redshift_dms_instance.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  table_mappings            = var.table_mappings_json
  replication_task_settings = var.replication_task_settings_json
  start_replication_task    = false # Important: prevent auto start
  lifecycle {
    ignore_changes = [replication_task_settings]
  }
}

