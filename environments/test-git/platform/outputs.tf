
#################################
# WAF (S3 Admin) 
#################################
output "s3_admin_waf" {
  description = "Key WAF details (trimmed). Null when WAF is disabled."
  value = local.enable_eb_waf ? {
    web_acl_arn    = module.s3_admin_waf[0].web_acl_arn
    web_acl_name   = module.s3_admin_waf[0].web_acl_name
    scope          = module.s3_admin_waf[0].web_acl_scope
    log_group_name = try(module.s3_admin_waf[0].log_group_name, null)
    rules_active   = module.s3_admin_waf[0].rules_active
  } : null
}
