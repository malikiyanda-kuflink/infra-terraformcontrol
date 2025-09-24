output "replication_instance_arn" {
  value = aws_dms_replication_instance.redshift_dms_instance.replication_instance_arn
}
output "replication_task_arn" {
  value = aws_dms_replication_task.redshift_dms_task.replication_task_arn
}

output "mysql_to_redshift_replication_instance_arn" {
  value = aws_dms_replication_instance.redshift_dms_instance.replication_instance_arn
}

output "mysql_to_redshift_replication_task_arn" {
  value = aws_dms_replication_task.redshift_dms_task.replication_task_arn
}

output "dms_assessment_results_arn" {
  value = aws_s3_bucket.dms_assessment_results.arn
}

output "dms_assessment_results_bucket" {
  value = aws_s3_bucket.dms_assessment_results.bucket
}