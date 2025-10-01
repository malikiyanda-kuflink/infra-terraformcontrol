# RDS Instance

# Primary instance (restored from snapshot)
resource "aws_db_instance" "restored_primary_rds_instance" {
  identifier          = var.db_name_identifier
  snapshot_identifier = var.db_snapshot_identifier

  # Still required by AWS even when restoring (some are ignored by the API)
  instance_class      = var.instance_class
  publicly_accessible = var.publicly_accessible
  storage_encrypted   = var.storage_encrypted
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  allocated_storage   = var.allocated_storage

  parameter_group_name   = var.db_parameter_group_name
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.rds_sg_id]

  username = var.db_username
  password = var.db_password

  copy_tags_to_snapshot   = true
  backup_retention_period = var.backup_retention_period


  tags = { Name = var.db_name_identifier, Role = "primary" }

  # ===== DATABASE INSIGHTS FOR READ REPLICA =====
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id

  # Enhanced Monitoring for replica
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_role_arn

  # CloudWatch Logs Exports for replica
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  lifecycle {
    ignore_changes = [
      db_name,
      username,
      password,
      snapshot_identifier
    ]
  }

  apply_immediately = true
}

# Optional read replica
resource "aws_db_instance" "restored_rds_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier          = "${var.db_name_identifier}-replica"
  instance_class      = var.replica_instance_class
  replicate_source_db = aws_db_instance.restored_primary_rds_instance.arn

  db_subnet_group_name = var.db_subnet_group_name
  parameter_group_name = var.db_parameter_group_name
  publicly_accessible  = var.publicly_accessible
  storage_encrypted    = var.storage_encrypted
  skip_final_snapshot  = var.skip_final_snapshot
  deletion_protection  = var.deletion_protection
  # final_snapshot_identifier = "${var.db_name_identifier}-final-${formatdate("YYYYMMDD-HHmmss", timestamp())}" # remove final_snapshot_identifier line (not needed if skipping)
  vpc_security_group_ids = [var.rds_sg_id]

  copy_tags_to_snapshot   = true
  backup_retention_period = var.backup_retention_period

  # CloudWatch Logs Exports for replica
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = {
    Name             = "${var.db_name_identifier}-replica"
    Role             = "read-replica"
    DatabaseInsights = "enabled"
  }

  apply_immediately = true
}


