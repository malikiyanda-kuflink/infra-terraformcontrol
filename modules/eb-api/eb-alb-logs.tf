data "aws_caller_identity" "me" {}
data "aws_partition" "part" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = var.alb_log_bucket
  force_destroy = true
}

# Block Public Access (defense-in-depth)
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Ownership enforced (disables ACLs)
resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

# Default encryption (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# (Optional) lifecycle to control storage cost
resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    id     = "expire-90d"
    status = "Enabled"
    expiration { days = 90 }
  }
}

# ALB access logs: allow only the service to write under AWSLogs/<account>/*
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowALBPutScopedToAccountAndPrefix",
        Effect : "Allow",
        Principal : { Service : "logdelivery.elasticloadbalancing.amazonaws.com" },
        Action : ["s3:PutObject"],
        Resource : "arn:${data.aws_partition.part.partition}:s3:::${aws_s3_bucket.alb_logs.id}/AWSLogs/${data.aws_caller_identity.me.account_id}/*",
        Condition : {
          StringEquals : {
            "aws:SourceAccount" : data.aws_caller_identity.me.account_id
          }
        }
      },
      {
        Sid : "AllowALBGetBucketAclScoped",
        Effect : "Allow",
        Principal : { Service : "logdelivery.elasticloadbalancing.amazonaws.com" },
        Action : ["s3:GetBucketAcl"],
        Resource : "arn:${data.aws_partition.part.partition}:s3:::${aws_s3_bucket.alb_logs.id}",
        Condition : {
          StringEquals : {
            "aws:SourceAccount" : data.aws_caller_identity.me.account_id
          }
        }
      },

      # Optional: explicit deny to everything else (tighten further)
      {
        Sid : "DenyNonALBPutToLogsPrefix",
        Effect : "Deny",
        Principal : "*",
        Action : "s3:PutObject",
        Resource : "arn:${data.aws_partition.part.partition}:s3:::${aws_s3_bucket.alb_logs.id}/AWSLogs/${data.aws_caller_identity.me.account_id}/*",
        Condition : {
          StringNotEquals : {
            "aws:PrincipalServiceName" : "logdelivery.elasticloadbalancing.amazonaws.com"
          }
        }
      }
    ]
  })
  depends_on = [
    aws_s3_bucket_public_access_block.alb_logs,
    aws_s3_bucket_ownership_controls.alb_logs
  ]
}
