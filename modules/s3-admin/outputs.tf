#################################
# S3 admin (Module Outputs)
#################################

output "bucket_name" {
  description = "Name of the S3 bucket (null when disabled/destroyed)."
  value       = try(aws_s3_bucket.this[0].bucket, null)
}

output "bucket_arn" {
  description = "ARN of the S3 bucket (null when disabled/destroyed)."
  value       = try(aws_s3_bucket.this[0].arn, null)
}

output "cloudfront_id" {
  description = "CloudFront distribution ID (null when disabled/destroyed)."
  value       = try(aws_cloudfront_distribution.this[0].id, null)
}

output "cloudfront_domain_name" {
  description = "CloudFront domain (null when disabled/destroyed)."
  value       = try(aws_cloudfront_distribution.this[0].domain_name, null)
}

output "admin_pipeline" {
  description = "admin pipeline details (null when site is disabled)."
  value = var.enable_s3_admin ? {
    pipeline_name   = aws_codepipeline.admin_pipeline[0].name
    artifact_bucket = var.admin_artifact_bucket
    build_project   = aws_codebuild_project.admin_build[0].name
    invalidate_job  = aws_codebuild_project.admin_invalidate_cache[0].name
  } : null
}