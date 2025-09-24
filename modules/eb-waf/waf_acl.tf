resource "aws_wafv2_web_acl" "backend_waf" {
  name        = "${var.name_prefix}-api-waf"
  scope       = var.scope
  description = "Parametrised WAF for ${var.name_prefix}-api-waf"

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

  # ---------- Managed groups (toggle + per-subrule COUNT) ----------
  dynamic "rule" {
    for_each = { for rg, enabled in local.enabled_groups : rg => enabled if enabled }

    content {
      name     = rule.key
      priority = local.rule_priority[rule.key]

      # Keep group default behaviour; override individual subrules to COUNT
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

  # ---------- Custom rule: admin paths (action driven by var.admin_rule_action) ----------
  rule {
    name     = "BlockAdminPathsNotFromTrustedIPs"
    priority = local.rule_priority["BlockAdminPathsNotFromTrustedIPs"]

    # Exactly one of these emits based on var.admin_rule_action
    dynamic "action" {
      for_each = upper(var.admin_rule_action) == "BLOCK" ? [1] : []
      content {
        block {}
      }
    }
    dynamic "action" {
      for_each = upper(var.admin_rule_action) == "COUNT" ? [1] : []
      content {
        count {}
      }
    }
    dynamic "action" {
      for_each = upper(var.admin_rule_action) == "ALLOW" ? [1] : []
      content {
        allow {}
      }
    }
    dynamic "action" {
      for_each = upper(var.admin_rule_action) == "CAPTCHA" ? [1] : []
      content {
        captcha {}
      }
    }
    dynamic "action" {
      for_each = upper(var.admin_rule_action) == "CHALLENGE" ? [1] : []
      content {
        challenge {}
      }
    }

    statement {
      and_statement {
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.admin_uri_regex.arn

            field_to_match {
              uri_path {}
            }

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }

        statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.trusted_ipv4.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${local.metric_base}_BlockAdminPaths"
      sampled_requests_enabled   = true
    }
  }

  # Web ACL-level visibility config (required)
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.metric_base}_webacl"
    sampled_requests_enabled   = true
  }
}



resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.alb_arn == null ? 0 : 1
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.backend_waf.arn

}


resource "aws_cloudwatch_log_group" "waf" {
  count             = var.logging.enabled ? 1 : 0
  name              = local.log_group_name
  retention_in_days = var.logging.retention_days
}

data "aws_iam_policy_document" "waf_logs" {
  count = var.logging.enabled && var.logging.create_policy ? 1 : 0

  statement {
    sid    = "AWSWAFLoggingPermissions"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    principals {
      type        = "Service"
      identifiers = ["waf.amazonaws.com"]
    }

    resources = ["${aws_cloudwatch_log_group.waf[0].arn}:*"]
  }
}


resource "aws_cloudwatch_log_resource_policy" "waf_logs" {
  count           = var.logging.enabled && var.logging.create_policy ? 1 : 0
  policy_name     = "${local.name}-AllowWAFLogging"
  policy_document = data.aws_iam_policy_document.waf_logs[0].json
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count                   = var.logging.enabled ? 1 : 0
  resource_arn            = aws_wafv2_web_acl.backend_waf.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
}
