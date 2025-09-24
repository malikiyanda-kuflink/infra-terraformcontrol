resource "aws_wafv2_regex_pattern_set" "admin_uri_regex" {
  name        = "${local.name}-admin-uri-regex"
  description = "Admin path regexes"
  scope       = var.scope

  dynamic "regular_expression" {
    for_each = var.admin_uri_regexes
    content { regex_string = regular_expression.value }
  }
}

resource "aws_wafv2_ip_set" "trusted_ipv4" {
  name               = "${local.name}-trusted-ipv4"
  scope              = var.scope
  description        = "Trusted office/VPN IPv4s for admin access"
  ip_address_version = "IPV4"
  addresses          = var.trusted_ip_cidrs
}
