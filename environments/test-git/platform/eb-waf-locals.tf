locals {
  # --------------------------------------
  # WAF CONFIGURATION (ENV-SCOPED) FOR EB ALB
  # Master toggle, ALB ARN discovery, rule modes, IP allowlists,
  # managed rule group selection and override behavior, plus logging.
  # --------------------------------------
  # WAF config (env-scoped) - compute layer
  # --------------------------------------
  # No ALB yet: keep null so association is skip
  alb_arn = null

  admin_rule_action = "COUNT" # or "COUNT"/ "BLOCK" / "ALLOW" / "CAPTCHA" / "CHALLENGE"
  trusted_ip_cidrs  = data.terraform_remote_state.foundation.outputs.kuflink_office_ip_cidrs
  admin_uri_regexes = [".*/admin/.*", ".*/wp-admin/.*"]

  waf_enable_groups = {
    common           = true
    ip_reputation    = true
    known_bad_inputs = true
    linux            = true
    php              = true
    sqli             = true
    anonymous_ip     = false
  }

  # Set noisy subrules to COUNT (others use default managed action)
  waf_overrides = {
    common           = ["SizeRestrictions_BODY", "CrossSiteScripting_BODY", "CrossSiteScripting_QUERYARGUMENTS", "CrossSiteScripting_COOKIE", "CrossSiteScripting_URIPATH"]
    ip_reputation    = []
    known_bad_inputs = []
    linux            = []
    php              = []
    sqli             = []
    anonymous_ip     = ["AnonymousIPList"]
  }

  waf_logging = {
    enabled        = true
    log_group_name = null # let the module default it
    retention_days = 30
    create_policy  = true
  }

}