module "eb_waf" {
  count             = local.enable_eb_waf ? 1 : 0
  source            = "../../../modules/eb-waf"
  name_prefix       = local.name_prefix
  name_prefix_upper = local.name_prefix_upper
  environment       = local.environment
  scope             = "REGIONAL"

  # Auto-associate to EB ALB if available
  alb_arn = null

  # Env-scoped inputs
  default_action_allow  = true
  admin_rule_action     = local.admin_rule_action
  trusted_ip_cidrs      = local.trusted_ip_cidrs
  admin_uri_regexes     = local.admin_uri_regexes
  enable_managed_groups = local.waf_enable_groups
  managed_overrides     = local.waf_overrides
  logging               = local.waf_logging
}