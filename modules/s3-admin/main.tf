resource "aws_codestarconnections_connection" "admin_github_connection" {
  name          = "kuflink-${var.environment}-connection"
  provider_type = "GitHub"
}

# ----------------------------
# S3 bucket (private)
# ----------------------------
resource "aws_s3_bucket" "this" {
  count         = var.enable_s3_admin ? 1 : 0
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy # lets TF delete even if objects exist

  tags = merge(
    {
      Name        = "${var.name_prefix}-admin-bucket"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "this" {
  count                   = var.enable_s3_admin ? 1 : 0
  bucket                  = aws_s3_bucket.this[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


