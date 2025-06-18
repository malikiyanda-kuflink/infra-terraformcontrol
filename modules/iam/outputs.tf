# Output the Backup Role ARN
output "backup_role_arn" {
  value = aws_iam_role.backup_role.arn
}

# Output the Backup Role Name (optional, some resources take name instead of ARN)
output "backup_role_name" {
  value = aws_iam_role.backup_role.name
}

output "ec2_test_instance_role_arn" {
  value = aws_iam_role.ec2_test_instance_role.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "eb_role_arn" {
  value = aws_iam_role.eb_role.arn
}

output "eb_instance_profile_arn" {
  value = aws_iam_instance_profile.eb_instance_profile.arn
}

