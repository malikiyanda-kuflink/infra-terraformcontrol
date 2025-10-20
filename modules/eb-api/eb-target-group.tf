# modules/eb-api/eb-target-group.tf

# --- Discover EB Target Groups for this environment ---
data "aws_resourcegroupstaggingapi_resources" "eb_tgs" {
  count = length(aws_elastic_beanstalk_environment.web_env) > 0 ? 1 : 0
  
  resource_type_filters = ["elasticloadbalancing:targetgroup"]

  tag_filter {
    key    = "elasticbeanstalk:environment-name"
    values = [var.web_env_name]
  }
  
  depends_on = [aws_elastic_beanstalk_environment.web_env]
}

# Discover the ALB
data "aws_lb" "eb_alb" {
  count = length(aws_elastic_beanstalk_environment.web_env) > 0 ? 1 : 0
  
  tags = {
    "elasticbeanstalk:environment-name" = var.web_env_name
  }
  
  depends_on = [aws_elastic_beanstalk_environment.web_env]
}

# Simplified locals - just get the primary TG ARN and dimension
locals {
  eb_tg_arns_raw = length(data.aws_resourcegroupstaggingapi_resources.eb_tgs) > 0 ? sort([
    for m in data.aws_resourcegroupstaggingapi_resources.eb_tgs[0].resource_tag_mapping_list : m.resource_arn
  ]) : []

  # Primary target group
  primary_tg_arn = try(local.eb_tg_arns_raw[0], null)
  
  # Extract dimension from ARN
  primary_tg_dimension = local.primary_tg_arn != null ? try(
    regex("targetgroup/.+$", local.primary_tg_arn),
    null
  ) : null

  # For compatibility with existing outputs
  eb_tg_arns       = local.eb_tg_arns_raw
  eb_tg_dimensions = [for arn in local.eb_tg_arns_raw : regex("targetgroup/.+$", arn)]
}

# HTTP to HTTPS redirect
data "aws_lb_listener" "http_listener" {
  count             = length(data.aws_lb.eb_alb) > 0 ? 1 : 0
  load_balancer_arn = data.aws_lb.eb_alb[0].arn
  port              = 80
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count        = length(data.aws_lb_listener.http_listener) > 0 ? 1 : 0
  listener_arn = data.aws_lb_listener.http_listener[0].arn
  priority     = 1

  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }

  condition {
    path_pattern { values = ["/*"] }
  }
}

# Outputs
output "eb_target_group_arns" {
  description = "All EB Target Group ARNs attached to this environment's ALB"
  value       = local.eb_tg_arns
}

output "eb_target_group_dimensions" {
  description = "Target group dimensions (targetgroup/<name>/<id>) for CloudWatch"
  value       = local.eb_tg_dimensions
}

output "eb_primary_target_group_arn" {
  description = "Primary EB Target Group ARN (first in sorted list)"
  value       = local.primary_tg_arn
}

output "eb_primary_target_group_dimension" {
  description = "Primary TG dimension (targetgroup/<name>/<id>)"
  value       = local.primary_tg_dimension
}