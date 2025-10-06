resource "aws_cloudwatch_dashboard" "waf_dashboard" {
  dashboard_name = "${var.name_prefix_upper}--API-WAF-Rules-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # {
      #           type = "text"
      #           x    = 0
      #           y    = 0
      #           width = 24
      #           height = 3
      #           properties = {
      #             markdown = <<EOT
      #   ## Regional WAF API Service Dashboard

      #   ### Overview
      #   This dashboard provides real-time monitoring and insights into the AWS WAF protection applied to the API services in the regional deployment. The key metrics displayed help track incoming requests, evaluate rule-based actions, and analyze potential security threats.

      #   It includes:
      #   - **Total Requests Blocked & Counted**
      #   - **Count Override for AWS Managed Rules (Common Rule Set & SQL Injection Rule Set)** – The number of requests that matched these rules but were overridden.

      #   This visualisation helps in fine-tuning WAF rules, optimising security, and identifying trends in web traffic protection.
      #   EOT
      #           }
      # },

      # {
      #   type = "log"
      #   x    = 12
      #   y    = 9
      #   width = 12
      #   height = 6
      #   properties = {
      #     query = "SOURCE '${local.log_group_name}' | fields @timestamp, @message | parse @message \"uri=\\\"*\\\"\" as uri | parse @message \"nonTerminatingMatchingRules=[{\\\"ruleId\\\":*\\\",action:*}]\" as parsedRule, parsedAction | filter parsedAction = 'COUNT' and parsedRule != 'SQLI_BODY' and parsedRule != 'SizeRestrictions_BODY'",
      #     region = "eu-west-2",
      #     title  = "Counted Requests Excluding - SQL_BODY & SizeRestrictions_BODY"
      #   }
      # },

      # Blocked Requests - Last 100
      {
        type   = "log",
        x      = 0,
        y      = 19, # (or whatever is the next free y position)
        width  = 12,
        height = 8,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"action":"*"' as action
  | parse @message '"uri":"*"' as uri
  | filter action = "BLOCK"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, uri, action
  EOT
          region = "eu-west-2",
          title  = "Blocked Requests - Last 100",
          view   = "table"
        }
      },

      # Allowed Requests - Last 100
      {
        type   = "log",
        x      = 12,
        y      = 19, # (stack it right below blocked requests)
        width  = 12,
        height = 8,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"action":"*"' as action
  | parse @message '"uri":"*"' as uri
  | filter action = "ALLOW"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, uri, action
  EOT
          region = "eu-west-2",
          title  = "Allowed Requests - Last 100",
          view   = "table"
        }
      },



      # Number->  Total Blocked and Counted Requests
      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 24
        height = 3
        properties = {
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", "${local.name}", "Region", "eu-west-2", "Rule", "ALL"],
            ["AWS/WAFV2", "CountedRequests", "WebACL", "${local.name}", "Region", "eu-west-2", "Rule", "ALL"],
            ["AWS/WAFV2", "AllowedRequests", "WebACL", "${local.name}", "Region", "eu-west-2", "Rule", "ALL"]
          ],
          stat           = "Sum",
          view           = "singleValue",
          region         = "eu-west-2",
          liveData       = true
          periodOverride = "auto"
          title          = "Total Blocked and Counted Requests"
        }
      },


      # All Counted Request Details
      {
        type   = "log"
        x      = 0
        y      = 9
        width  = 12
        height = 10
        properties = {
          query  = <<EOT
        SOURCE '${local.log_group_name}'
        | fields @timestamp, @message
        | parse @message '"uri":"*"' as uri
        | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
        | filter parsedAction = "COUNT"
        | sort @timestamp desc
        # | limit 100
        | display @timestamp, parsedRule, uri, parsedAction, @message
        EOT
          region = "eu-west-2",
          title  = "All Counted Request Details",
          view   = "table"
        }
      },

      # Counted Requests by Rule (Pie)      
      {
        type   = "metric",
        x      = 14,
        y      = 9,
        width  = 12,
        height = 10,
        properties = {
          metrics = [
            # Common Rule Set
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "NoUserAgent_HEADER", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "UserAgent_BadBots_HEADER", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "CrossSiteScripting_BODY", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "CrossSiteScripting_URIPATH", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "GenericLFI_URIPATH", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "RestrictedExtensions_URIPATH", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "GenericLFI_QUERYARGUMENTS", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "SizeRestrictions_QUERYSTRING", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "ManagedRuleGroupRule", "SizeRestrictions_URIPATH", "WebACL", "${local.name}", "Region", "eu-west-2"],

            # Known Bad Inputs Rule Set
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesKnownBadInputsRuleSet", "ManagedRuleGroupRule", "ExploitablePaths_URIPATH", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesKnownBadInputsRuleSet", "ManagedRuleGroupRule", "Log4JRCE_HEADER", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesKnownBadInputsRuleSet", "ManagedRuleGroupRule", "Log4JRCE_URIPATH", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesKnownBadInputsRuleSet", "ManagedRuleGroupRule", "Log4JRCE_QUERYSTRING", "WebACL", "${local.name}", "Region", "eu-west-2"],

            # Linux Rule Set
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesLinuxRuleSet", "ManagedRuleGroupRule", "LFI_URIPATH", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesLinuxRuleSet", "ManagedRuleGroupRule", "LFI_QUERYSTRING", "WebACL", "${local.name}", "Region", "eu-west-2"],

            # PHP Rule Set
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesPHPRuleSet", "ManagedRuleGroupRule", "PHPHighRiskMethodslocaliables_BODY", "WebACL", "${local.name}", "Region", "eu-west-2"],
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesPHPRuleSet", "ManagedRuleGroupRule", "PHPHighRiskMethodslocaliables_QUERYSTRING", "WebACL", "${local.name}", "Region", "eu-west-2"],

            # SQLi Rule Set
            ["AWS/WAFV2", "CountedRequests", "ManagedRuleGroup", "AWSManagedRulesSQLiRuleSet", "ManagedRuleGroupRule", "SQLi_BODY", "WebACL", "${local.name}", "Region", "eu-west-2"]
          ],
          stat           = "Sum",
          view           = "pie",
          region         = "eu-west-2",
          title          = "Counted Requests by Rule (Pie)",
          period         = 86400,  # 1 day
          legendPosition = "right" # vertical key
        }
      },


      # Blocked Requests by Managed Rule Set (Pie)
      # {
      #   type = "metric"
      #   x    = 14
      #   y    = 9
      #   width = 10
      #   height = 10
      #   properties = {
      #     metrics = [
      #       ["AWS/WAFV2", "BlockedRequests", "ManagedRuleGroup", "AWSManagedRulesCommonRuleSet", "WebACL", "${local.name}", "Region", "eu-west-2"],
      #       ["AWS/WAFV2", "BlockedRequests", "ManagedRuleGroup", "AWSManagedRulesAmazonIpReputationList", "WebACL", "${local.name}", "Region", "eu-west-2"],
      #       ["AWS/WAFV2", "BlockedRequests", "ManagedRuleGroup", "AWSManagedRulesKnownBadInputsRuleSet", "WebACL", "${local.name}", "Region", "eu-west-2"],
      #       ["AWS/WAFV2", "BlockedRequests", "ManagedRuleGroup", "AWSManagedRulesLinuxRuleSet", "WebACL", "${local.name}", "Region", "eu-west-2"],
      #       ["AWS/WAFV2", "BlockedRequests", "ManagedRuleGroup", "AWSManagedRulesPHPRuleSet", "WebACL", "${local.name}", "Region", "eu-west-2"],
      #       ["AWS/WAFV2", "BlockedRequests", "ManagedRuleGroup", "AWSManagedRulesSQLiRuleSet", "WebACL", "${local.name}", "Region", "eu-west-2"]
      #     ],
      #     stat   = "Sum",
      #     view   = "pie",
      #     region = "eu-west-2",
      #     title  = "Blocked Requests by Managed Rule Set (Pie)",
      #     period = 86400
      #   }
      # },

      # {
      #   type = "log"
      #   x    = 0
      #   y    = 15
      #   width = 24
      #   height = 6
      #   properties = {
      #     query = "SOURCE '${local.log_group_name}' | stats count() as requestCount by uri | sort requestCount desc | limit 20",
      #     region = "eu-west-2",
      #     title  = "Counted Requests: Count"
      #   }
      # },

      # TEXT -> Counted Requests by AWS Managed Rule Groups
      {
        type   = "text",
        x      = 0,
        y      = 20, # right before the managed rule group tables start
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
      ## 🚧 Counted Requests by AWS Managed Rule Groups 🚧
      EOT
        }
      },

      # TEXT -> Counted Requests by AWSManagedRulesCommonRuleSet
      {
        type   = "text",
        x      = 14,
        y      = 20,
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
      ## 🚧 Counted Requests by AWSManagedRulesCommonRuleSet 🚧
      EOT
        }
      },


      # AWSManagedRulesCommonRuleSet
      {
        type   = "log",
        x      = 14, # <--- Put it next to the table widget that starts at x=0
        y      = 22, # Same row as your table
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
    SOURCE '${local.log_group_name}'
    | fields @timestamp, @message
    | parse @message '"uri":"*"' as uri
    | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
    | filter parsedAction = "COUNT"
    | filter parsedRule in [
      "NoUserAgent_HEADER", "UserAgent_BadBots_HEADER", "SizeRestrictions_QUERYSTRING",
      "SizeRestrictions_Cookie_HEADER", "SizeRestrictions_BODY", "SizeRestrictions_URIPATH", 
      "EC2MetaDataSSRF_BODY", "EC2MetaDataSSRF_COOKIE", "EC2MetaDataSSRF_URIPATH", "EC2MetaDataSSRF_QUERYARGUMENTS",
      "GenericLFI_QUERYARGUMENTS", "GenericLFI_URIPATH", "GenericLFI_BODY",
      "RestrictedExtensions_URIPATH", "RestrictedExtensions_QUERYARGUMENTS",
      "GenericRFI_QUERYARGUMENTS", "GenericRFI_BODY", "GenericRFI_URIPATH",
      "CrossSiteScripting_COOKIE", "CrossSiteScripting_QUERYARGUMENTS", "CrossSiteScripting_BODY", "CrossSiteScripting_URIPATH"
    ]
    | stats count() as requestCount by parsedRule
    | sort requestCount desc
    # | limit 20
    EOT
          region = "eu-west-2",
          title  = "Request Count by Rule - AWSManagedRulesCommonRuleSet",
          view   = "table" # Important: leave as table to show rule + count
        }
      },


      {
        type   = "log",
        x      = 0,
        y      = 22,
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "NoUserAgent_HEADER", "UserAgent_BadBots_HEADER", "SizeRestrictions_QUERYSTRING",
    "SizeRestrictions_Cookie_HEADER", "SizeRestrictions_BODY", "SizeRestrictions_URIPATH",
    "EC2MetaDataSSRF_BODY", "EC2MetaDataSSRF_COOKIE", "EC2MetaDataSSRF_URIPATH", "EC2MetaDataSSRF_QUERYARGUMENTS",
    "GenericLFI_QUERYARGUMENTS", "GenericLFI_URIPATH", "GenericLFI_BODY",
    "RestrictedExtensions_URIPATH", "RestrictedExtensions_QUERYARGUMENTS",
    "GenericRFI_QUERYARGUMENTS", "GenericRFI_BODY", "GenericRFI_URIPATH",
    "CrossSiteScripting_COOKIE", "CrossSiteScripting_QUERYARGUMENTS", "CrossSiteScripting_BODY", "CrossSiteScripting_URIPATH"
  ]
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesCommonRuleSet",
          view   = "table"
        }
      },

      # TEXT -> Counted Requests by AWSManagedRulesAmazonIpReputationList
      {
        type   = "text",
        x      = 14,
        y      = 30,
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
      ## 🚧 Counted Requests by AWSManagedRulesAmazonIpReputationList 🚧
      EOT
        }
      },

      # AWSManagedRulesAmazonIpReputationList
      {
        type   = "log",
        x      = 14, # place next to your detailed request table
        y      = 32, # align with the y-position of the detailed table
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in ["AWSManagedIPReputationList", "AWSManagedReconnaissanceList", "AWSManagedIPDDoSList"]
  | stats count() as requestCount by parsedRule
  | sort requestCount desc
  # | limit 20
  EOT
          region = "eu-west-2",
          title  = "Request Count by Rule - AWSManagedRulesAmazonIpReputationList",
          view   = "table"
        }
      },

      {
        type   = "log",
        x      = 0,
        y      = 32,
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in ["AWSManagedIPReputationList", "AWSManagedReconnaissanceList", "AWSManagedIPDDoSList"]
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesAmazonIpReputationList Group",
          view   = "table"
        }
      },

      # TEXT -> Counted Requests by AWSManagedRulesKnownBadInputsRuleSet
      {
        type   = "text",
        x      = 14,
        y      = 40,
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
      ## 🚧 Counted Requests by AWSManagedRulesKnownBadInputsRuleSet 🚧
      EOT
        }
      },

      # AWSManagedRulesKnownBadInputsRuleSet

      {
        type   = "log",
        x      = 14, # placed to the right of the detailed table
        y      = 42, # same y as the table to align
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "JavaDeserializationRCE_BODY", "JavaDeserializationRCE_URIPATH", "JavaDeserializationRCE_QUERYSTRING",
    "JavaDeserializationRCE_HEADER", "Host_localhost_HEADER", "PROPFIND_METHOD", "ExploitablePaths_URIPATH",
    "Log4JRCE_QUERYSTRING", "Log4JRCE_BODY", "Log4JRCE_URIPATH", "Log4JRCE_HEADER"
  ]
  | stats count() as requestCount by parsedRule
  | sort requestCount desc
  # | limit 20
  EOT
          region = "eu-west-2",
          title  = "Request Count by Rule - AWSManagedRulesKnownBadInputsRuleSet",
          view   = "table"
        }
      },

      {
        type   = "log",
        x      = 0,
        y      = 42, # (Move down so it doesn't overlap the last one)
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "JavaDeserializationRCE_BODY", "JavaDeserializationRCE_URIPATH", "JavaDeserializationRCE_QUERYSTRING",
    "JavaDeserializationRCE_HEADER", "Host_localhost_HEADER", "PROPFIND_METHOD", "ExploitablePaths_URIPATH",
    "Log4JRCE_QUERYSTRING", "Log4JRCE_BODY", "Log4JRCE_URIPATH", "Log4JRCE_HEADER"
  ]
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesKnownBadInputsRuleSet",
          view   = "table"
        }
      },

      # TEXT -> Counted Requests by AWSManagedRulesLinuxRuleSet
      {
        type   = "text",
        x      = 14,
        y      = 50,
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
      ## 🚧 Counted Requests by AWSManagedRulesLinuxRuleSet 🚧
      EOT
        }
      },

      # AWSManagedRulesLinuxRuleSet

      {
        type   = "log",
        x      = 14, # placed to the right of the table
        y      = 52, # same y to align nicely
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "LFI_URIPATH", "LFI_QUERYSTRING", "LFI_HEADER"
  ]
  | stats count() as requestCount by parsedRule
  | sort requestCount desc
  # | limit 20
  EOT
          region = "eu-west-2",
          title  = "Request Count by Rule - AWSManagedRulesLinuxRuleSet",
          view   = "table"
        }
      },

      {
        type   = "log",
        x      = 0,
        y      = 52, # (move down to avoid overlap)
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "LFI_URIPATH", "LFI_QUERYSTRING", "LFI_HEADER"
  ]
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesLinuxRuleSet",
          view   = "table"
        }
      },

      # TEXT -> Counted Requests by AWSManagedRulesPHPRuleSet
      {
        type   = "text",
        x      = 14,
        y      = 60,
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
      ## 🚧 Counted Requests by AWSManagedRulesPHPRuleSet 🚧
      EOT
        }
      },

      # AWSManagedRulesPHPRuleSet

      {
        type   = "log",
        x      = 14, # place next to the main PHP table
        y      = 62, # same y to align horizontally
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "PHPHighRiskMethodslocaliables_HEADER", 
    "PHPHighRiskMethodslocaliables_QUERYSTRING", 
    "PHPHighRiskMethodslocaliables_BODY"
  ]
  | stats count() as requestCount by parsedRule
  | sort requestCount desc
  # | limit 20
  EOT
          region = "eu-west-2",
          title  = "Request Count by Rule - AWSManagedRulesPHPRuleSet",
          view   = "table"
        }
      },


      {
        type   = "log",
        x      = 0,
        y      = 62, # (shift down to stack neatly)
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "PHPHighRiskMethodslocaliables_HEADER", 
    "PHPHighRiskMethodslocaliables_QUERYSTRING", 
    "PHPHighRiskMethodslocaliables_BODY"
  ]
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesPHPRuleSet",
          view   = "table"
        }
      },

      # TEXT -> Counted Requests by AWSManagedRulesSQLiRuleSet
      {
        type   = "text",
        x      = 14,
        y      = 70,
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
      ## 🚧 Counted Requests by AWSManagedRulesSQLiRuleSet 🚧
      EOT
        }
      },


      # AWSManagedRulesSQLiRuleSet

      {
        type   = "log",
        x      = 14,
        y      = 72,
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
SOURCE '${local.log_group_name}'
| fields @timestamp, @message
| parse @message '"uri":"*"' as uri
| parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
| filter parsedAction = "COUNT"
| filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
]
| stats count() as requestCount by parsedRule, uri
| sort requestCount desc
# | limit 20
EOT
          region = "eu-west-2",
          title  = "Request Count by Rule and URI - AWSManagedRulesSQLiRuleSet",
          view   = "table"
        }
      },

      {
        type   = "log",
        x      = 0,
        y      = 72, # Stack neatly below PHP
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
  ]
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Only Uri -> /api/v
      {
        type   = "log",
        x      = 14,
        y      = 72,
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
SOURCE '${local.log_group_name}'
| fields @timestamp, @message
| parse @message '"uri":"*"' as uri
| parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
| filter parsedAction = "COUNT"
| filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
]
| filter uri like "/api/v"
| stats count() as requestCount by parsedRule, uri
| sort requestCount desc
# | limit 20
EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet Only Uri -> /api/v",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Excluding Uri -> /api/v
      {
        type   = "log",
        x      = 14,
        y      = 72,
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
SOURCE '${local.log_group_name}'
| fields @timestamp, @message
| parse @message '"uri":"*"' as uri
| parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
| filter parsedAction = "COUNT"
| filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
]
| filter uri not like /^\/api\/v.*/
| stats count() as requestCount by parsedRule, uri
| sort requestCount desc
# | limit 20
EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet Excluding Uri -> /api/v",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Excluding Uri -> /api/v3/get-user-wallet-information
      {
        type   = "log",
        x      = 0,
        y      = 72, # Stack neatly below PHP
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
  ]
  | filter uri != "/api/v3/get-user-wallet-information"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet- Exclude - /api/v3/get-user-wallet-information",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Only Uri -> /api/v3/admin/search-for-user
      {
        type   = "log",
        x      = 0,
        y      = 72, # Stack neatly below PHP
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
  ]
  | filter uri == "/api/v3/admin/search-for-user"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet- Only -/api/v3/admin/search-for-user",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Only Uri -> /api/v3/get-user-wallet-information

      {
        type   = "log",
        x      = 0,
        y      = 72,
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
  ]
  | filter uri == "/api/v3/get-user-wallet-information"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet- Only -/api/v3/get-user-wallet-information",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Only Uri -> /api/v3/get-only-transactions

      {
        type   = "log",
        x      = 14,
        y      = 72,
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
  ]
  | filter uri == "/api/v3/get-only-transactions"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet- Only -/api/v3/get-only-transactions",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Only Uri -> /api/v3/get-user-topup-orders
      {
        type   = "log",
        x      = 14,
        y      = 72,
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
  ]
  | filter uri == "/api/v3/get-user-topup-orders"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet- Only -/api/v3/get-user-topup-orders",
          view   = "table"
        }
      },

      # AWSManagedRulesSQLiRuleSet Only Uri -> /api/v3/get-user-wallet-information-export
      {
        type   = "log",
        x      = 0,
        y      = 72,
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in [
    "SQLiExtendedPatterns_QUERYARGUMENTS",
    "SQLi_QUERYARGUMENTS",
    "SQLi_BODY",
    "SQLi_COOKIE",
    "SQLi_URIPATH"
  ]
  | filter uri == "/api/v3/get-user-wallet-information-export"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
  EOT
          region = "eu-west-2",
          title  = "Counted Requests - AWSManagedRulesSQLiRuleSet- Only -/api/v3/get-user-wallet-information-export",
          view   = "table"
        }
      },

      # TEXT -> Counted Requests by BlockAdminPathsNotFromTrustedIPs
      {
        type   = "text",
        x      = 0,
        y      = 80,
        width  = 24,
        height = 2,
        properties = {
          markdown = <<EOT
  ## 🚧 Counted Requests by BlockAdminPathsNotFromTrustedIPs 🚧
  EOT
        }
      },


      {
        type   = "log",
        x      = 0,
        y      = 82,
        width  = 14,
        height = 7,
        properties = {
          query  = <<EOT
  SOURCE '${local.log_group_name}'
  | fields @timestamp, @message
  | parse @message '"uri":"*"' as uri
  | parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
  | filter parsedAction = "COUNT"
  | filter parsedRule in ["BlockAdminPathsNotFromTrustedIPs"]
  | filter uri == "/api/v3/admin/natwest-open-banking-integration-hook"
  | sort @timestamp desc
  # | limit 100
  | display @timestamp, parsedRule, uri, parsedAction, @message
EOT
          region = "eu-west-2",
          title  = "Counted Requests - BlockAdminPathsNotFromTrustedIPs - Only - /api/v3/admin/natwest-open-banking-integration-hook",
          view   = "table"
        }
      },


      {
        type   = "log",
        x      = 14,
        y      = 82, # adjust based on the last widget y-coordinate
        width  = 10,
        height = 7,
        properties = {
          query  = <<EOT
SOURCE '${local.log_group_name}'
| fields @timestamp, @message
| parse @message '"uri":"*"' as uri
| parse @message ',"nonTerminatingMatchingRules":[{"ruleId":"*","action":"*"' as parsedRule, parsedAction
| filter parsedAction = "COUNT"
| filter parsedRule in [
    "BlockAdminPathsNotFromTrustedIPs"
]
| stats count() as requestCount by parsedRule, uri
| sort requestCount desc
# | limit 20
EOT
          region = "eu-west-2",
          title  = "Counted Requests - BlockAdminPathsNotFromTrustedIPs by Rule and URI",
          view   = "table"
        }
      }

    ]
  })
}

