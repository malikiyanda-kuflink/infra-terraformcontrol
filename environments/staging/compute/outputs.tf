output "test_instance_arn" {
  description = "ARN of the EC2 test instance"
  value       = module.ec2_test_instance.test_instance_arn
}
