# =========================
# Elastic Beanstalk (App)
# =========================
output "eb_application_name" {
  value = aws_elastic_beanstalk_application.kuflink_app.name
}

output "eb_application_arn" {
  value = aws_elastic_beanstalk_application.kuflink_app.arn
}

# =========================
# Web Environment (Core)
# =========================
output "eb_environment_name" {
  value = aws_elastic_beanstalk_environment.web_env.name
}

output "web_env_id" {
  value = aws_elastic_beanstalk_environment.web_env.id
}

output "web_env_arn" {
  value = aws_elastic_beanstalk_environment.web_env.arn
}

output "web_env_cname" {
  value = aws_elastic_beanstalk_environment.web_env.cname
}

output "web_env_url" {
  value = "https://${aws_elastic_beanstalk_environment.web_env.cname}"
}

output "environment_url" {
  value = aws_elastic_beanstalk_environment.web_env.endpoint_url
}

output "web_env_tier" {
  value = aws_elastic_beanstalk_environment.web_env.tier
}

# Helpful infra lists exposed by the EB env (may be empty depending on config)
output "web_env_load_balancers" {
  value = try(aws_elastic_beanstalk_environment.web_env.load_balancers, [])
}

output "web_env_autoscaling_groups" {
  value = try(aws_elastic_beanstalk_environment.web_env.autoscaling_groups, [])
}

output "web_env_launch_configurations" {
  value = try(aws_elastic_beanstalk_environment.web_env.launch_configurations, [])
}

output "web_env_instances" {
  value = try(aws_elastic_beanstalk_environment.web_env.instances, [])
}

# =========================
# Worker Environment (Core)
# =========================
output "eb_worker_environment_name" {
  value = aws_elastic_beanstalk_environment.worker_env.name
}

output "worker_env_id" {
  value = aws_elastic_beanstalk_environment.worker_env.id
}

output "worker_env_arn" {
  value = aws_elastic_beanstalk_environment.worker_env.arn
}

# Worker tiers may not expose these; guard with try()
output "worker_env_cname" {
  value = try(aws_elastic_beanstalk_environment.worker_env.cname, null)
}

output "worker_env_endpoint_url" {
  value = try(aws_elastic_beanstalk_environment.worker_env.endpoint_url, null)
}

# For worker tiers, provider may surface the queues list
output "worker_env_queues" {
  value = try(aws_elastic_beanstalk_environment.worker_env.queues, [])
}

# =========================
# SQS (Worker queue)
# =========================
# outputs-sqs.tf
output "worker_queue_name" { value = aws_sqs_queue.worker_queue.name }
output "worker_queue_url" { value = aws_sqs_queue.worker_queue.url }
output "worker_queue_arn" { value = aws_sqs_queue.worker_queue.arn }

# =========================
# Useful pass-throughs
# =========================
output "security_group_id" {
  value = var.eb_web_app_sg_id
}

output "instance_profile_arn" {
  value = var.eb_instance_profile_arn
}

output "service_role_arn" {
  value = var.eb_role_arn
}

output "ssl_certificate_arn" {
  value = var.ssl_certificate_arn
}

output "vpc_id" {
  value = var.vpc_id
}

output "subnets_private" {
  value = var.private_subnet_ids
}

output "subnets_public" {
  value = var.public_subnet_ids
}

###########################################
# OUTPUTS
##########################################
output "sns_topic_arn" {
  value = try(aws_sns_topic.eb_deployments[0].arn, null)
}

# output "sns_subscription_arn" {
#   value = try(aws_sns_topic_subscription.eb_deployments_email_subscription[0].arn, null)
# }

output "eb_deployments_topic_arn" {
  value       = try(aws_sns_topic.eb_deployments[0].arn, null)
  description = "EB deployments SNS topic ARN"
}

output "pipeline_notifications_topic_arn" {
  value       = try(aws_sns_topic.pipeline_notifications[0].arn, null)
  description = "Pipeline notifications SNS topic ARN"
}

output "pipeline_notification_rule_arn" {
  value       = try(aws_codestarnotifications_notification_rule.pipeline_notification[0].arn, null)
  description = "CodeStar Notifications rule ARN"
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer created by Elastic Beanstalk"
  value       = data.aws_lb.eb_alb.arn
}

output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = data.aws_lb.eb_alb.dns_name
}

output "load_balancer_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer"
  value       = data.aws_lb.eb_alb.zone_id
}

# =========================
# Compact summary objects
# =========================
output "web_env_summary" {
  value = {
    name                  = aws_elastic_beanstalk_environment.web_env.name
    arn                   = aws_elastic_beanstalk_environment.web_env.arn
    tier                  = aws_elastic_beanstalk_environment.web_env.tier
    cname                 = aws_elastic_beanstalk_environment.web_env.cname
    url                   = "https://${aws_elastic_beanstalk_environment.web_env.cname}"
    endpoint_url          = aws_elastic_beanstalk_environment.web_env.endpoint_url
    load_balancers        = try(aws_elastic_beanstalk_environment.web_env.load_balancers, [])
    autoscaling_groups    = try(aws_elastic_beanstalk_environment.web_env.autoscaling_groups, [])
    launch_configurations = try(aws_elastic_beanstalk_environment.web_env.launch_configurations, [])
    instances             = try(aws_elastic_beanstalk_environment.web_env.instances, [])
  }
}

output "worker_env_summary" {
  value = {
    name         = aws_elastic_beanstalk_environment.worker_env.name
    arn          = aws_elastic_beanstalk_environment.worker_env.arn
    tier         = aws_elastic_beanstalk_environment.worker_env.tier
    cname        = try(aws_elastic_beanstalk_environment.worker_env.cname, null)
    endpoint_url = try(aws_elastic_beanstalk_environment.worker_env.endpoint_url, null)
    queues       = try(aws_elastic_beanstalk_environment.worker_env.queues, [])
    sqs = {
      name = aws_sqs_queue.worker_queue.name
      url  = aws_sqs_queue.worker_queue.url
      arn  = aws_sqs_queue.worker_queue.arn
    }
  }

}
