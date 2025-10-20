# modules/eb-api/local.tf

locals {
  # Dashboard
  dashboard_name = "${var.application_name}-API-Rate-Limiting-Monitoring-Dashboard"

  alb_dimension = length(data.aws_lb.eb_alb) > 0 ? try(
    regex("app/.+$", data.aws_lb.eb_alb[0].arn),
    ""
  ) : ""

  target_group_dimension = try(local.primary_tg_dimension, "")
}