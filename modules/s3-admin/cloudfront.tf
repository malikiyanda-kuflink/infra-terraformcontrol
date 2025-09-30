# ----------------------------
# CloudFront (OAC-based)
# RECOMMENDED: replaces legacy OAI with Origin Access Control (SigV4)
# ----------------------------

# OAC for S3 origin (SigV4 signing)
resource "aws_cloudfront_origin_access_control" "oac_admin" {
  count                             = var.enable_s3_admin ? 1 : 0
  name                              = "${var.name_prefix}-admin-oac"
  description                       = "${var.name_prefix} OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# Deterministic S3 bucket policy allowing ONLY this CloudFront distribution (via SourceArn)
# NOTE: This references the distribution ARN below; that’s OK (no cycle).
data "aws_iam_policy_document" "s3_cf_oac" {
  count = var.enable_s3_admin ? 1 : 0

  statement {
    sid    = "AllowAdminCloudFrontOAC"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this[0].arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cf" {
  count  = var.enable_s3_admin ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = data.aws_iam_policy_document.s3_cf_oac[0].json
}

# Security headers policy (unchanged)
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  count = var.enable_s3_admin ? 1 : 0
  name  = "${var.name_prefix}-admin-security-headers-policy"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "geolocation=(), microphone=()"
      override = true
    }
  }
}


resource "aws_cloudfront_distribution" "this" {
  count               = var.enable_s3_admin ? 1 : 0
  comment             = "${var.name_prefix} Admin"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  web_acl_id = var.admin_waf_arn
  depends_on = [var.admin_waf_arn]

  aliases = var.cf_aliases
  # lifecycle { ignore_changes = [aliases] }

  origin {
    domain_name              = aws_s3_bucket.this[0].bucket_regional_domain_name
    origin_id                = "origin_main"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_admin[0].id
  }

  default_cache_behavior {
    target_origin_id       = "origin_main" # default; Edge can switch it
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    # keep your SPA zero-cache behavior
    min_ttl     = var.min_ttl_seconds
    default_ttl = var.default_ttl_seconds
    max_ttl     = var.default_ttl_seconds

    forwarded_values {
      query_string = true
      cookies { forward = "all" }
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers[0].id
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }  

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.cf_cert_arn # must be in us-east-1
    ssl_support_method  = "sni-only"
  }

  tags = merge(
    {
      Name        = "${var.name_prefix}-admin-cloudfront"
      Environment = var.environment
    },
    var.tags
  )
}

