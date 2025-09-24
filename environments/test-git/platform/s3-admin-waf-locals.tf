locals {
  # --------------------------------------
  # ADMIN WAF CONFIGURATION (ENV-SCOPED) FOR EB ALB
  # Master toggle, ALB ARN discovery, rule modes, IP allowlists,
  # managed rule group selection and override behavior, plus logging.
  # --------------------------------------
  # WAF config (env-scoped) -  platform layer
  # --------------------------------------
  admin_ip_action        = "BLOCK" # or "COUNT"/ "BLOCK" / "ALLOW" / "CAPTCHA" / "CHALLENGE"
  admin_trusted_ip_cidrs = ["${data.terraform_remote_state.foundation.outputs.office_ip}"]

  admin_waf_enable_groups = {
    common           = true
    ip_reputation    = true
    known_bad_inputs = true
    sqli             = true
    admin_protection = true
    anonymous_ip     = false
  }

  # Set noisy subrules to COUNT (others use default managed action)
  admin_waf_overrides = {
    common           = []
    ip_reputation    = []
    known_bad_inputs = []
    sqli             = []
    admin_protection = []
    anonymous_ip     = ["AnonymousIPList"]
  }

  admin_waf_logging = {
    enabled        = true
    log_group_name = null # let the module default it
    retention_days = 30
    create_policy  = true
  }
}