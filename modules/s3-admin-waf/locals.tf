locals {
  name            = "${var.name_prefix}-admin-waf"
  metric_base_raw = var.environment

  # Sanitize to [A-Za-z0-9_]: replace hyphens/spaces with underscores
  metric_base = replace(replace(local.metric_base_raw, "-", "_"), " ", "_")

  rule_order = [
    # Managed groups first so they can still block bad requests
    "AWSManagedRulesCommonRuleSet",
    "AWSManagedRulesAmazonIpReputationList",
    "AWSManagedRulesKnownBadInputsRuleSet",
    "AWSManagedRulesSQLiRuleSet",
    "AWSManagedRulesAnonymousIpList",
    "AWSManagedRulesAdminProtectionRuleSet",

    # Then allow if IP is trusted
    "AllowTrustedIPs",
  ]

  rule_priority = zipmap(local.rule_order, range(length(local.rule_order)))

  enabled_groups = {
    AWSManagedRulesCommonRuleSet          = var.enable_managed_groups.common
    AWSManagedRulesAmazonIpReputationList = var.enable_managed_groups.ip_reputation
    AWSManagedRulesKnownBadInputsRuleSet  = var.enable_managed_groups.known_bad_inputs
    AWSManagedRulesSQLiRuleSet            = var.enable_managed_groups.sqli
    AWSManagedRulesAnonymousIpList        = var.enable_managed_groups.anonymous_ip
    AWSManagedRulesAdminProtectionRuleSet = var.enable_managed_groups.admin_protection
  }

  override_map = {
    AWSManagedRulesCommonRuleSet          = var.managed_overrides.common
    AWSManagedRulesAmazonIpReputationList = var.managed_overrides.ip_reputation
    AWSManagedRulesKnownBadInputsRuleSet  = var.managed_overrides.known_bad_inputs
    AWSManagedRulesSQLiRuleSet            = var.managed_overrides.sqli
    AWSManagedRulesAnonymousIpList        = var.managed_overrides.anonymous_ip
    AWSManagedRulesAdminProtectionRuleSet = var.managed_overrides.admin_protection
  }

  log_group_name = coalesce(var.logging.log_group_name, "aws-waf-logs-${local.name}")
}
