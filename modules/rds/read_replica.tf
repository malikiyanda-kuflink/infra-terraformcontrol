resource "aws_db_instance" "new_rds_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier                 = "${var.db_name_identifier}-replica"
  instance_class             = var.replica_instance_class
  replicate_source_db        = aws_db_instance.new_primary_rds_instance.arn
  db_subnet_group_name       = var.db_subnet_group_name
  vpc_security_group_ids     = [var.rds_sg_id]
  parameter_group_name       = var.db_parameter_group_name
  engine                     = var.engine
  engine_version             = var.engine_version
  publicly_accessible        = var.publicly_accessible
  deletion_protection        = var.deletion_protection
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  storage_encrypted          = var.storage_encrypted
  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  skip_final_snapshot        = var.skip_final_snapshot

  tags = {
    Name = "${aws_db_instance.new_primary_rds_instance.identifier}-replica"
    Role = "read-replica"
  }
}
