
module "s3_admin_waf" {
  count  = local.enable_s3_admin_waf ? 1 : 0
  source = "../../../modules/s3-admin-waf"

  providers = { aws.use1 = aws.use1 } # makes module default provider us-east-1


  name_prefix = local.name_prefix
  environment = local.environment
  scope       = "CLOUDFRONT"

  # Env-scoped inputs
  default_action_allow  = false
  admin_ip_action       = local.admin_ip_action
  trusted_ip_cidrs      = local.admin_trusted_ip_cidrs
  admin_uri_regexes     = local.admin_uri_regexes
  enable_managed_groups = local.admin_waf_enable_groups
  managed_overrides     = local.admin_waf_overrides
  logging               = local.admin_waf_logging
}
