resource "aws_wafv2_web_acl" "admin_waf" {
  # (recommend mapping the module provider at call-site; if not, keep:)
  provider    = aws.use1
  name        = "${var.name_prefix}-admin-waf"
  scope       = var.scope
  description = "Parametrised WAF for ${var.name_prefix}-admin-waf"

  # Ensure exactly one of allow/block exists even if the var is null/unknown.
  default_action {
    dynamic "allow" {
      for_each = var.default_action_allow == true ? [1] : []
      content {
        # empty
      }
    }
    dynamic "block" {
      for_each = var.default_action_allow != true ? [1] : []
      content {
        # empty
      }
    }
  }

  # ---- Custom rule: Allow IPs  in allowlist (global, no path filter) ----
  rule {
    name     = "AllowTrustedIPs"
    priority = local.rule_priority["AllowTrustedIPs"]

    # Always ALLOW here (we're using default_action = block)
    action {
      allow {}
    }

    # Match when source IP IS in the trusted set
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.trusted_ipv4.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.metric_base}_AllowTrustedIPs"
      sampled_requests_enabled   = true
    }
  }

  # ---- Managed groups ----
  dynamic "rule" {
    for_each = { for rg, enabled in local.enabled_groups : rg => enabled if enabled }
    content {
      name     = rule.key
      priority = local.rule_priority[rule.key]
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          name        = rule.key
          vendor_name = "AWS"
          dynamic "rule_action_override" {
            for_each = toset(local.override_map[rule.key])
            content {
              name = rule_action_override.value
              action_to_use {
                count {}
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.metric_base}_${rule.key}"
        sampled_requests_enabled   = true
      }
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.metric_base}_webacl"
    sampled_requests_enabled   = true
  }
}
