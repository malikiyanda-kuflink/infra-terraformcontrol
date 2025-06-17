output "backup_role_arn" {
  description = "ARN of the IAM Backup Role"
  value       = module.iam_terraform.backup_role_arn
}

output "ec2_test_instance_role_arn" {
  description = "ARN of the EC2 test instance IAM Role"
  value       = module.iam_terraform.ec2_test_instance_role_arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM Role"
  value       = module.iam_terraform.lambda_role_arn
}

output "eb_role_arn" {
  description = "ARN of the Elastic Beanstalk IAM Role"
  value       = module.iam_terraform.eb_role_arn
}

output "eb_instance_profile_arn" {
  description = "ARN of the Elastic Beanstalk EC2 Instance Profile"
  value       = module.iam_terraform.eb_instance_profile_arn
}
