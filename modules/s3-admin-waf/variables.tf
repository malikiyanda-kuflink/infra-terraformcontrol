variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "scope" {
  type    = string
  default = "CLOUDFRONT"
}

variable "trusted_ip_cidrs" {
  type    = list(string)
  default = []
}

variable "admin_uri_regexes" {
  type    = list(string)
  default = [".*/admin/.*"]
}

# variables.tf
variable "admin_ip_action" {
  description = "Action for the admin-path rule: BLOCK, COUNT, ALLOW, CAPTCHA, or CHALLENGE."
  type        = string
  default     = "BLOCK"
  validation {
    condition     = contains(["BLOCK", "COUNT", "ALLOW", "CAPTCHA", "CHALLENGE"], upper(var.admin_ip_action))
    error_message = "admin_ip_action must be one of BLOCK, COUNT, ALLOW, CAPTCHA, CHALLENGE."
  }
}

variable "default_action_allow" {
  type    = bool
  default = true
}

variable "enable_managed_groups" {
  type = object({
    common           = bool
    ip_reputation    = bool
    known_bad_inputs = bool
    sqli             = bool
    anonymous_ip     = bool
    admin_protection = bool
  })
  default = {
    common           = true
    ip_reputation    = true
    known_bad_inputs = true
    sqli             = true
    anonymous_ip     = true
    admin_protection = true
  }
}

variable "managed_overrides" {
  type = object({
    common           = list(string)
    ip_reputation    = list(string)
    known_bad_inputs = list(string)
    sqli             = list(string)
    anonymous_ip     = list(string)
    admin_protection = list(string)
  })
  default = {
    common           = []
    ip_reputation    = []
    known_bad_inputs = []
    sqli             = []
    anonymous_ip     = []
    admin_protection = []
  }
}

variable "logging" {
  type = object({
    enabled        = bool
    log_group_name = string
    retention_days = number
    create_policy  = bool
  })
  default = {
    enabled        = true
    log_group_name = null
    retention_days = 30
    create_policy  = true
  }
}
