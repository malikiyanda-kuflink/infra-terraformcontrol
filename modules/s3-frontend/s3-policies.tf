# Deterministic S3 bucket policy allowing ONLY this CloudFront distribution (via SourceArn)
# NOTE: This references the distribution ARN below; that’s OK (no cycle).
data "aws_iam_policy_document" "s3_cf_oac" {
  count = var.enable_s3_frontend ? 1 : 0

  statement {
    sid    = "AllowCloudFrontOAC"
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
  count  = var.enable_s3_frontend ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = data.aws_iam_policy_document.s3_cf_oac[0].json
}

# Maintenance bucket policy allowing CloudFront (single distro) via OAC
data "aws_iam_policy_document" "maintenance_cf_oac" {
  count = var.enable_s3_frontend ? 1 : 0

  statement {
    sid    = "AllowCloudFrontOACMaintenance"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.maintenance[0].arn}/*"]

    # IMPORTANT: trust the single CF distribution
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_maintenance_cf" {
  count  = var.enable_s3_frontend ? 1 : 0
  bucket = aws_s3_bucket.maintenance[0].id
  policy = data.aws_iam_policy_document.maintenance_cf_oac[0].json
}