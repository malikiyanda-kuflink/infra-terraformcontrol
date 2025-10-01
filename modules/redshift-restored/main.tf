resource "aws_redshift_cluster" "restored_primary_redshift_cluster" {
  # Restore source + new name
  cluster_identifier  = var.redshift_cluster_identifier_name
  snapshot_identifier = var.redshift_snapshot_identifier

  # Allowed overrides at restore time
  node_type                 = var.redshift_node_type
  master_username           = var.redshift_username
  database_name             = var.redshift_database_name
  port                      = var.redshift_port
  cluster_subnet_group_name = var.redshift_subnet_group_name
  vpc_security_group_ids    = [var.redshift_sg_id]

  # Encryption: set ONLY if source snapshot was UNENCRYPTED and you want encryption
  encrypted            = var.redshift_encrypted
  enhanced_vpc_routing = var.redshift_enhanced_vpc_routing
  publicly_accessible  = var.redshift_publicly_accessible
  skip_final_snapshot  = var.redshift_skip_final_snapshot

  iam_roles = [
    var.redshift_role_arn,
    var.redshift_dms_role_arn,
    var.dms_access_for_endpoint_arn
  ]

  tags = { Name = var.redshift_cluster_identifier_name }
  lifecycle {
    ignore_changes = [database_name]
  }
}




resource "aws_redshift_scheduled_action" "daily_pause" {
  name     = var.redshift_daily_pause #"${local.env}-redshiftdaily-pause"
  iam_role = var.redshift_role_arn
  schedule = "cron(0 18 * * ? *)" # 18:00 UTC (6PM)
  target_action {
    pause_cluster {
      cluster_identifier = aws_redshift_cluster.restored_primary_redshift_cluster.cluster_identifier
    }
  }

}

resource "aws_redshift_scheduled_action" "daily_resume" {
  name     = var.redshift_daily_resume #"${local.env}-redshiftdaily-resume"
  iam_role = var.redshift_role_arn
  schedule = "cron(0 7 * * ? *)" # 07:00 UTC (7AM)
  target_action {
    resume_cluster {
      cluster_identifier = aws_redshift_cluster.restored_primary_redshift_cluster.cluster_identifier
    }
  }

}
