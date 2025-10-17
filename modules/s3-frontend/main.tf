resource "aws_codestarconnections_connection" "frontend_github_connection" {
  name          = "kuflink-${var.environment}-github-connection"
  provider_type = "GitHub"
}

# ----------------------------
# S3 bucket (private)
# ----------------------------
resource "aws_s3_bucket" "this" {
  count         = var.enable_s3_frontend ? 1 : 0
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy # lets TF delete even if objects exist

  tags = merge(
    {
      Name        = "${var.name_prefix}-frontend-bucket"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "this" {
  count                   = var.enable_s3_frontend ? 1 : 0
  bucket                  = aws_s3_bucket.this[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# ----------------------------
# Maintenance S3 bucket (separate)
# ----------------------------
resource "aws_s3_bucket" "maintenance" {
  count         = var.enable_s3_frontend ? 1 : 0
  bucket        = var.maintenance_bucket_name
  force_destroy = var.bucket_force_destroy

  tags = merge(
    {
      Name        = "${var.name_prefix}-maintenance-bucket"
      Environment = var.environment
      Purpose     = "maintenance-page"
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "maintenance" {
  count                   = var.enable_s3_frontend ? 1 : 0
  bucket                  = aws_s3_bucket.maintenance[0].id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
