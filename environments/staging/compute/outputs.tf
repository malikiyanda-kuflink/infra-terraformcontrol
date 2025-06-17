## EC2 Test Instance Outputs
output "test_instance_arn" {
  description = "ARN of the EC2 test instance"
  value       = module.ec2_test_instance.test_instance_arn
}

output "test_instance_id" {
  description = "ID of the EC2 test instance"
  value       = module.ec2_test_instance.test_instance_id
}

output "test_instance_private_ip" {
  description = "private IP of the EC2 test instance"
  value       = module.ec2_test_instance.test_instance_private_ip
}

## Bastion Outputs
output "bastion_sg_id" {
  description = "Security group ID for the Bastion host"
  value       = module.bastion-terraform.bastion_sg_id
}

output "bastion_instance_id" {
  description = "ID of the Bastion EC2 instance"
  value       = module.bastion-terraform.bastion_instance_id
}

# Web App Outputs
output "web_app_env_name" {
  description = "Elastic Beanstalk Web environment name"
  value       = module.web_app.eb_environment_name
}

output "web_app_endpoint_url" {
  description = "Elastic Beanstalk environment endpoint URL"
  value       = module.web_app.environment_url
}

output "web_app_eb_worker_environment_name" {
  description = "Elastic Beanstalk Worker environment name"
  value       = module.web_app.eb_worker_environment_name
}
