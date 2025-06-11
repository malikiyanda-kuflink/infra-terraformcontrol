# Fetch caller identity
data "aws_caller_identity" "current" {}

# RDS Instance
resource "aws_db_instance" "rds_db" {
  db_name                    = null
  snapshot_identifier        = var.db_test_snapshot_identifier

  allocated_storage          = var.allocated_storage
  storage_type               = var.storage_type
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  identifier                 = var.db_test_name_identifier
  username                   = var.db_test_username
  password                   = var.db_test_password
  
  parameter_group_name       = var.db_parameter_group_name
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = var.db_subnet_group_name


  backup_retention_period    = var.backup_retention_period
  skip_final_snapshot        = var.skip_final_snapshot
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible        = var.publicly_accessible
  deletion_protection        = var.deletion_protection
  multi_az                   = var.multi_az
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_encrypted          = var.storage_encrypted

  tags = {
    Name        = var.rds_name_tag
    Environment = var.environment
  }

  # This is required so that Terraform does not destroy the restored DB when password or snapshot_identifier changes
  lifecycle {
    ignore_changes = [
      db_name,
      password,
      snapshot_identifier
    ]
  }
}

