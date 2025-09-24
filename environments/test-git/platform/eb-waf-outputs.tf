#################################
# WAF (EB) 
#################################
output "eb_waf" {
  description = "Key WAF details (trimmed). Null when WAF is disabled."
  value = local.enable_eb_waf ? {
    web_acl_arn             = module.eb_waf[0].web_acl_arn
    web_acl_name            = module.eb_waf[0].web_acl_name
    scope                   = module.eb_waf[0].web_acl_scope
    associated_resource_arn = try(module.eb_waf[0].associated_resource_arn, null)
    log_group_name          = try(module.eb_waf[0].log_group_name, null)
    rules_active            = module.eb_waf[0].rules_active
  } : null
}