# --- Discover EB Target Groups for this environment ---
data "aws_resourcegroupstaggingapi_resources" "eb_tgs" {
  count = length(aws_elastic_beanstalk_environment.web_env) > 0 ? 1 : 0
  resource_type_filters = ["elasticloadbalancing:targetgroup"]

  tag_filter {
    key    = "elasticbeanstalk:environment-name"
    values = [var.eb_web_environment_name] # same var you used above
  }
}

# Get details for each TG so we can confirm it's attached to this ALB
locals {
  eb_tg_arns_raw = sort([for m in data.aws_resourcegroupstaggingapi_resources.eb_tgs.resource_tag_mapping_list : m.resource_arn])
}

data "aws_lb_target_group" "eb_tg_details" {
  for_each = toset(local.eb_tg_arns_raw)
  arn      = each.value
}

# Keep only TGs actually attached to our discovered ALB
locals {
  eb_tg_arns = [
    for arn, tg in data.aws_lb_target_group.eb_tg_details :
    arn if contains(tg.load_balancer_arns, data.aws_lb.eb_alb.arn)
  ]

  eb_tg_dimensions = [for arn in local.eb_tg_arns : regex("targetgroup/.+$", arn)]

  primary_tg_arn       = try(local.eb_tg_arns[0], null)
  primary_tg_dimension = try(local.eb_tg_dimensions[0], null)
}

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
