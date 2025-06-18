# Fetch Load Balancer ARN associated with the Elastic Beanstalk environment
data "aws_lb" "load_balancer" {
  arn = element(tolist(aws_elastic_beanstalk_environment.kuflink_env.load_balancers), 0)
}

# Associate WAF with the ALB that Elastic Beanstalk created
resource "aws_wafv2_web_acl_association" "backend_waf_assoc" {
  resource_arn = data.aws_lb.load_balancer.arn
  web_acl_arn  = aws_wafv2_web_acl.backend_waf.arn
}

# Create WAF ACL (REGIONAL for ALB)
resource "aws_wafv2_web_acl" "backend_waf" {
  name        = "test-api-waf"
  scope       = "REGIONAL" # Required for ALB (Elastic Beanstalk)
  description = "TEST WAF for Kuflink API backend"

  default_action {
    allow {}
  }




  # Add AWS Managed Rule Groups




  # AWSManagedRulesCommonRuleSet-> All Blocked(Except SizeRestrictions_BODY Counted)
  # rule {
  #   name     = "AWSManagedRulesCommonRuleSet"
  #   priority = 1
  #   override_action {
  #     none {} # Keep default behavior for all except overridden rules
  #   }
  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesCommonRuleSet"
  #       vendor_name = "AWS"
  #       rule_action_override {
  #         name = "SizeRestrictions_BODY"
  #         action_to_use {
  #           count {} # Override to Count instead of Allow
  #         }
  #       }
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "CoreRuleSet"
  #     sampled_requests_enabled   = true
  #   }
  # }


  # AWSManagedRulesCommonRuleSet -> All Counted
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {} # Allow overrides below to work at sub-rule level
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          name = "CrossSiteScripting_URIPATH"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "CrossSiteScripting_BODY"
          action_to_use {
            count {}
          }
        }
        rule_action_override {
          name = "CrossSiteScripting_QUERYARGUMENTS"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "CrossSiteScripting_COOKIE"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_Cookie_HEADER"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "NoUserAgent_HEADER"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "UserAgent_BadBots_HEADER"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_QUERYSTRING"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_COOKIE_HEADER"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_BODY"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "SizeRestrictions_URIPATH"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_BODY"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_COOKIE"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_URIPATH"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_QUERYARGUMENTS"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "GenericLFI_QUERYARGUMENTS"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "GenericLFI_URIPATH"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "GenericLFI_BODY"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "RestrictedExtensions_URIPATH"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "RestrictedExtensions_QUERYARGUMENTS"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "GenericRFI_QUERYARGUMENTS"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "GenericRFI_BODY"
          action_to_use {
            count {}
          }
        }

        rule_action_override {
          name = "GenericRFI_URIPATH"
          action_to_use {
            count {}
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CoreRuleSet"
      sampled_requests_enabled   = true
    }
  }


  # AWSManagedRulesAmazonIpReputationList -> All Blocked
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 2

    override_action {
      none {} # Use the default action from the rule group (block)
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AmazonIpReputation"
      sampled_requests_enabled   = true
    }
  }

  # AWSManagedRulesAmazonIpReputationList -> All Counted
  # rule {
  #   name     = "AWSManagedRulesAmazonIpReputationList"
  #   priority = 2
  #   override_action {
  #     none {} # Allow subrule overrides below to work
  #   }
  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesAmazonIpReputationList"
  #       vendor_name = "AWS"

  #       rule_action_override {
  #         name = "AWSManagedIPReputationList"
  #         action_to_use {
  #           count {}
  #         }
  #       }

  #       rule_action_override {
  #         name = "AWSManagedReconnaissanceList"
  #         action_to_use {
  #           count {}
  #         }
  #       }

  #       rule_action_override {
  #         name = "AWSManagedIPDDoSList"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "AmazonIpReputation"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # AWSManagedRulesKnownBadInputsRuleSet -> All Blocked 
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet" # Blocks bad input patterns
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # AWSManagedRulesKnownBadInputsRuleSet - All Counted
  # rule {
  #   name     = "AWSManagedRulesKnownBadInputsRuleSet"
  #   priority = 3
  #   override_action {
  #     none {} # Allow individual rule overrides
  #   }
  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesKnownBadInputsRuleSet"
  #       vendor_name = "AWS"

  #       rule_action_override {
  #         name = "JavaDeserializationRCE_BODY"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "JavaDeserializationRCE_URIPATH"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "JavaDeserializationRCE_QUERYSTRING"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "JavaDeserializationRCE_HEADER"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "Host_localhost_HEADER"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "PROPFIND_METHOD"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "ExploitablePaths_URIPATH"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "Log4JRCE_QUERYSTRING"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "Log4JRCE_BODY"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "Log4JRCE_URIPATH"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "Log4JRCE_HEADER"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "KnownBadInputs"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # AWSManagedRulesLinuxRuleSet -> All Blocked
  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 4

    override_action {
      none {} # Use the default behavior (block)
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "LinuxOSProtection"
      sampled_requests_enabled   = true
    }
  }

  # AWSManagedRulesLinuxRuleSet -> All Counted
  # rule {
  #   name     = "AWSManagedRulesLinuxRuleSet"
  #   priority = 4
  #   override_action {
  #     none {} # Allow individual overrides
  #   }
  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesLinuxRuleSet"
  #       vendor_name = "AWS"

  #       rule_action_override {
  #         name = "LFI_URIPATH"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "LFI_QUERYSTRING"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "LFI_HEADER"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "LinuxOSProtection"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # AWSManagedRulesPHPRuleSet -> All Blocked
  rule {
    name     = "AWSManagedRulesPHPRuleSet"
    priority = 5

    override_action {
      none {} # Use default action from the managed rule set (which is block)
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "PHPProtection"
      sampled_requests_enabled   = true
    }
  }

  # AWSManagedRulesSQLiRuleSet ->  All Blocked
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 6

    override_action {
      none {} # No per-rule overrides; all rules will use default action (BLOCK)
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLDatabase"
      sampled_requests_enabled   = true
    }
  }

  # AWSManagedRulesPHPRuleSet -> All Counted
  # rule {
  #   name     = "AWSManagedRulesPHPRuleSet"
  #   priority = 5
  #   override_action {
  #     none {} # Allow per-rule override
  #   }
  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesPHPRuleSet"
  #       vendor_name = "AWS"

  #       rule_action_override {
  #         name = "PHPHighRiskMethodsVariables_HEADER"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "PHPHighRiskMethodsVariables_QUERYSTRING"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "PHPHighRiskMethodsVariables_BODY"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "PHPProtection"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # AWSManagedRulesSQLiRuleSet -> Blocked (Except SQLiBody)
  # rule {
  #   name     = "AWSManagedRulesSQLiRuleSet"
  #   priority = 6

  #   override_action {
  #     none {} # Use per-rule overrides instead of allowing all
  #   }

  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesSQLiRuleSet"
  #       vendor_name = "AWS"

  #       # Only override SQLi_BODY to count; all others will block
  #       rule_action_override {
  #         name = "SQLi_BODY"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "SQLDatabase"
  #     sampled_requests_enabled   = true
  #   }
  # }

  # AWSManagedRulesSQLiRuleSet -> All Counted
  # rule {
  #   name     = "AWSManagedRulesSQLiRuleSet"
  #   priority = 6
  #   override_action {
  #     none {} # Allow per-rule override
  #   }
  #   statement {
  #     managed_rule_group_statement {
  #       name        = "AWSManagedRulesSQLiRuleSet"
  #       vendor_name = "AWS"

  #       rule_action_override {
  #         name = "SQLiExtendedPatterns_QUERYARGUMENTS"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "SQLi_QUERYARGUMENTS"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "SQLi_BODY"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "SQLi_COOKIE"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #       rule_action_override {
  #         name = "SQLi_URIPATH"
  #         action_to_use {
  #           count {}
  #         }
  #       }
  #     }
  #   }
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "SQLDatabase"
  #     sampled_requests_enabled   = true
  #   }
  # }

  #BlockAdminPathsNotFromTrustedIPs -> Blocked
  rule {
    name     = "BlockAdminPathsNotFromTrustedIPs"
    priority = 7

    action {
      block {}
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
                arn = aws_wafv2_ip_set.office_vpn_ip.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockAdminPathsNotFromTrustedIPs"
    }
  }



  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "backend-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "api_waf_logging" {
  resource_arn = aws_wafv2_web_acl.backend_waf.arn

  log_destination_configs = [
    aws_cloudwatch_log_group.waf_log_group.arn
  ]
}

resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "aws-waf-logs-test-API-WAF-Logs"
  retention_in_days = 30
}

data "aws_iam_policy_document" "allow_waf_logging_doc" {
  statement {
    sid    = "AWSWAFLoggingPermissions"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["waf.amazonaws.com"]
    }

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["${aws_cloudwatch_log_group.waf_log_group.arn}:*"]

  }
}

resource "aws_cloudwatch_log_resource_policy" "allow_waf_logging" {
  policy_name     = "Test-AllowWAFLogging"
  policy_document = data.aws_iam_policy_document.allow_waf_logging_doc.json
}

resource "aws_wafv2_regex_pattern_set" "admin_uri_regex" {
  name        = "admin-uri-regex"
  description = "Match paths containing /admin/"
  scope       = "REGIONAL"

  regular_expression {
    regex_string = ".*/admin/.*"
  }
}

resource "aws_wafv2_ip_set" "office_vpn_ip" {
  name               = "OfficeVPN-IP-Test"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = [
    "89.197.135.242/32" # office IP
  ]
}
