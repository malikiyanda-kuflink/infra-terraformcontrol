output "eb_environment_name" {
  value = aws_elastic_beanstalk_environment.kuflink_env.name
}

output "environment_url" {
  value = aws_elastic_beanstalk_environment.kuflink_env.endpoint_url
}

output "eb_worker_environment_name" {
  value = aws_elastic_beanstalk_environment.worker-env.name # or wherever ELB name is defined
}

output "web_app_sg_id" {
  description = "Security Group ID of the EB web app"
  value       = aws_security_group.elb_security_group.id
}
