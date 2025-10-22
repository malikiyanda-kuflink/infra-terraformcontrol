# output "dbt_elastic_ip" {
#   value = aws_eip.dbt_eip.public_ip
# }

output "dbt_instance_id" {
  value = aws_instance.dbt_host.id
}

output "dbt_private_ip" {
  value = aws_instance.dbt_host.private_ip
}


output "dbt_alb_dns_name" {
  value       = aws_lb.dbt_docs.dns_name
  description = "DNS name of the ALB for accessing dbt docs"
}

output "dbt_docs_url" {
  value       = "http://${aws_lb.dbt_docs.dns_name}"
  description = "URL to access dbt docs"
}

output "dbt_docs_subdomain" {
  value       = var.dbt_docs_subdomain
  description = "Subdomain for accessing dbt docs"
}

# Outputs
# ----------------------------------------------------------------------------
# These values will be used in GitHub Actions and documentation
# ----------------------------------------------------------------------------
output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.app.name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
}

output "codedeploy_bucket_name" {
  description = "S3 bucket name for CodeDeploy artifacts"
  value       = aws_s3_bucket.codedeploy_bucket.id
}

output "sns_topic_arn" {
  description = "ARN of SNS topic for deployment notifications"
  value       = aws_sns_topic.codedeploy_notifications.arn
}