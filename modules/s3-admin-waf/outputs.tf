# modules/eb-waf/outputs.tf

# --- Core Web ACL info ---
output "web_acl_id" {
  description = "WAFv2 Web ACL ID"
  value       = aws_wafv2_web_acl.admin_waf.id
}

output "web_acl_arn" {
  description = "WAFv2 Web ACL ARN"
  value       = aws_wafv2_web_acl.admin_waf.arn
}

output "web_acl_name" {
  description = "WAFv2 Web ACL name"
  value       = aws_wafv2_web_acl.admin_waf.name
}

output "web_acl_scope" {
  description = "Scope for this Web ACL (REGIONAL or CLOUDFRONT)"
  value       = var.scope
}

# --- Helpful for dashboards/queries ---
output "metric_base" {
  description = "Sanitized base used for CloudWatch metric names"
  value       = local.metric_base
}

output "managed_rule_metric_names" {
  description = "Map of enabled managed rule groups -> CloudWatch metric names"
  value = {
    for k, enabled in local.enabled_groups :
    k => "${local.metric_base}_${k}" if enabled
  }
}

output "custom_rule_metric_names" {
  description = "Metric names for custom rules included in this ACL"
  value = {
    BlockAdminPathsNotFromTrustedIPs = "${local.metric_base}_BlockAdminPaths"
  }
}

output "trusted_ip_set_id" {
  description = "Trusted IPv4 IPSet ID used by the admin rule"
  value       = aws_wafv2_ip_set.trusted_ipv4.id
}

output "trusted_ip_set_arn" {
  description = "Trusted IPv4 IPSet ARN used by the admin rule"
  value       = aws_wafv2_ip_set.trusted_ipv4.arn
}


# --- Logging (optional) ---
output "logging_enabled" {
  description = "Whether WAF logging is enabled"
  value       = var.logging.enabled
}

output "log_group_name" {
  description = "CloudWatch Log Group name used for WAF logs (null if disabled)"
  value       = try(aws_cloudwatch_log_group.waf[0].name, null)
}

output "log_group_arn" {
  description = "CloudWatch Log Group ARN used for WAF logs (null if disabled)"
  value       = try(aws_cloudwatch_log_group.waf[0].arn, null)
}

output "log_resource_policy_name" {
  description = "Name of the CloudWatch Logs resource policy for WAF (null if not created)"
  value       = try(aws_cloudwatch_log_resource_policy.waf_logs[0].policy_name, null)
}

output "logging_configuration_id" {
  description = "ID of the aws_wafv2_web_acl_logging_configuration (null if disabled)"
  value       = try(aws_wafv2_web_acl_logging_configuration.this[0].id, null)
}

# Ordered list of rule names that are active in this Web ACL
output "rules_active" {
  description = "Active WAF rules in evaluation order."
  value = [
    for name in local.rule_order :
    name
    if(
      name == "AllowTrustedIPs" ||           # custom rule always present in this module
      try(local.enabled_groups[name], false) # managed groups gated by enable_managed_groups
    )
  ]
}

# Optional: also expose just the enabled managed groups as a list
output "managed_groups_enabled" {
  description = "Enabled AWS managed rule groups."
  value       = [for k, v in local.enabled_groups : k if v]
}
