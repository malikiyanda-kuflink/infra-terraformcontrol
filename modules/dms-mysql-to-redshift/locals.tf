locals {
  dms_task_name   = aws_dms_replication_task.redshift_dms_task.id
  dms_instance_id = aws_dms_replication_instance.redshift_dms_instance.replication_instance_id
  region          = var.region
  dashboard_name  = var.dms_dashboard_name
}
