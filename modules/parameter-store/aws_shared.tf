# ---------------------------------------------------------------#
# Public Key SSM Parameters for SSH Access 
# ---------------------------------------------------------------#
data "aws_ssm_parameter" "ssh_key_parameter_name" { name = "DevOpsPublicKey" }


# foundation/parameter_store.tf 
variable "environment" {
  type = string
}

# Route53 data sources
data "aws_ssm_parameter" "route53_zone_name" {
  name = "/kuflink/${var.environment}/route53-zone-name"
}

data "aws_ssm_parameter" "staging_hosted_zone_id" {
  name = "/kuflink/${var.environment}/staging-hosted-zone-id"
}

data "aws_ssm_parameter" "cloudfront_zone_id" {
  name = "/kuflink/${var.environment}/cloudfront-zone-id"
}

# Email data sources
data "aws_ssm_parameter" "build_notification_email" {
  name = "/kuflink/${var.environment}/build-notification-email"
}

data "aws_ssm_parameter" "ops_notification_email" {
  name = "/kuflink/${var.environment}/ops-notification-email"
}

# AWS ARN data sources
data "aws_ssm_parameter" "cloudfront_cert_arn" {
  name = "/kuflink/${var.environment}/cloudfront-cert-arn"
}

data "aws_ssm_parameter" "codestar_connection_arn" {
  name = "/kuflink/${var.environment}/codestar-connection-arn"
}

# Repository data sources
data "aws_ssm_parameter" "admin_repo" {
  name = "/kuflink/${var.environment}/admin-repo"
}

data "aws_ssm_parameter" "frontend_repo" {
  name = "/kuflink/${var.environment}/frontend-repo"
}

data "aws_ssm_parameter" "api_repo" {
  name = "/kuflink/${var.environment}/api-repo"
}

# Infrastructure data sources
data "aws_ssm_parameter" "ec2_key_name" {
  name = "/kuflink/${var.environment}/ec2-key-name"
}

data "aws_ssm_parameter" "worker_queue_name" {
  name = "/kuflink/${var.environment}/worker-queue-name"
}

# Email outputs - reuse the same parameter for multiple outputs
output "admin_email" {
  value       = data.aws_ssm_parameter.build_notification_email.value
  description = "Admin build notification email"
}

output "frontend_email" {
  value       = data.aws_ssm_parameter.build_notification_email.value
  description = "Frontend build notification email"
}

output "notification_email" {
  value       = data.aws_ssm_parameter.ops_notification_email.value
  description = "Operations notification email"
}

output "pipeline_emails" {
  value       = [data.aws_ssm_parameter.ops_notification_email.value]
  description = "Pipeline notification emails as list"
}

# AWS ARN outputs
output "cloudfront_cert_arn" {
  value       = data.aws_ssm_parameter.cloudfront_cert_arn.value
  description = "CloudFront SSL certificate ARN"
}

output "codestar_connection_arn" {
  value       = data.aws_ssm_parameter.codestar_connection_arn.value
  description = "CodeStar GitHub connection ARN"
}

# Repository outputs
output "admin_repo" {
  value       = data.aws_ssm_parameter.admin_repo.value
  description = "Admin UI repository name"
}

output "frontend_repo" {
  value       = data.aws_ssm_parameter.frontend_repo.value
  description = "Frontend repository name"
}

output "api_repo" {
  value       = data.aws_ssm_parameter.api_repo.value
  description = "API repository name"
}

# Infrastructure outputs
output "ec2_key_name" {
  value       = data.aws_ssm_parameter.ec2_key_name.value
  description = "EC2 SSH key pair name"
}

output "worker_queue_name" {
  value       = data.aws_ssm_parameter.worker_queue_name.value
  description = "SQS worker queue name"
}

# Route53 outputs
output "aws_route53_zone" {
  value       = data.aws_ssm_parameter.route53_zone_name.value
  description = "Primary Route53 hosted zone name"
}

output "staging_hosted_zone_id" {
  value       = data.aws_ssm_parameter.staging_hosted_zone_id.value
  description = "Staging environment hosted zone ID"
}

output "cloudfront_zone_id" {
  value       = data.aws_ssm_parameter.cloudfront_zone_id.value
  description = "CloudFront hosted zone ID"
}