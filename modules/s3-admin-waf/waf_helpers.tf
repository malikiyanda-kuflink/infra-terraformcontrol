resource "aws_wafv2_ip_set" "trusted_ipv4" {
  provider           = aws.use1
  name               = "${local.name}-trusted-ipv4"
  scope              = var.scope
  description        = "Trusted office/VPN IPv4s for internal admin access"
  ip_address_version = "IPV4"
  addresses          = var.trusted_ip_cidrs
}

resource "aws_cloudwatch_log_group" "waf" {
  provider          = aws.use1
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
  # provider        = aws.use1
  count           = var.logging.enabled && var.logging.create_policy ? 1 : 0
  policy_name     = "${local.name}-AllowWAFLogging"
  policy_document = data.aws_iam_policy_document.waf_logs[0].json
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  # provider                = aws.use1
  count                   = var.logging.enabled ? 1 : 0
  resource_arn            = aws_wafv2_web_acl.admin_waf.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]

  depends_on = [
    aws_cloudwatch_log_group.waf,               # log group exists
    aws_cloudwatch_log_resource_policy.waf_logs # policy attached
  ]
}
