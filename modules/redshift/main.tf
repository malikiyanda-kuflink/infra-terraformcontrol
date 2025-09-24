resource "aws_redshift_cluster" "new_primary_redshift_cluster" {
  cluster_identifier = var.redshift_cluster_identifier_name
  node_type          = var.redshift_node_type
  number_of_nodes    = var.redshift_num_of_nodes

  skip_final_snapshot = var.redshift_skip_final_snapshot
  publicly_accessible = var.redshift_publicly_accessible
  encrypted           = var.redshift_encrypted

  database_name   = var.redshift_database_name
  master_username = var.redshift_username
  master_password = var.redshift_password
  port            = var.redshift_port

  vpc_security_group_ids       = [var.redshift_sg_id]
  cluster_subnet_group_name    = var.redshift_subnet_group_name
  cluster_parameter_group_name = var.redshift_parameter_group_name
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
  name     = var.redshift_daily_pause
  iam_role = var.redshift_role_arn
  schedule = "cron(0 18 * * ? *)" # 18:00 UTC (6PM)
  target_action {
    pause_cluster {
      cluster_identifier = aws_redshift_cluster.new_primary_redshift_cluster.cluster_identifier
    }
  }

}

resource "aws_redshift_scheduled_action" "daily_resume" {
  name     = var.redshift_daily_resume
  iam_role = var.redshift_role_arn
  schedule = "cron(0 7 * * ? *)" # 07:00 UTC (7AM)
  target_action {
    resume_cluster {
      cluster_identifier = aws_redshift_cluster.new_primary_redshift_cluster.cluster_identifier
    }
  }

}
