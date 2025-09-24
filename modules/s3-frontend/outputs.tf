#################################
# S3 Frontend (Module Outputs)
#################################

output "bucket_name" {
  description = "Name of the S3 bucket (null when disabled/destroyed)."
  value       = try(aws_s3_bucket.this[0].bucket, null)
}

output "maintenance_bucket_name" {
  value = try(aws_s3_bucket.maintenance[0].bucket, null)
}

output "bucket_arn" {
  description = "ARN of the S3 bucket (null when disabled/destroyed)."
  value       = try(aws_s3_bucket.this[0].arn, null)
}

output "maintenance_bucket_arn" {
  description = "ARN of the S3 bucket (null when disabled/destroyed)."
  value       = try(aws_s3_bucket.maintenance[0].arn, null)
}

output "cloudfront_id" {
  description = "CloudFront distribution ID (null when disabled/destroyed)."
  value       = try(aws_cloudfront_distribution.this[0].id, null)
}

output "cloudfront_domain_name" {
  description = "CloudFront domain (null when disabled/destroyed)."
  value       = try(aws_cloudfront_distribution.this[0].domain_name, null)
}

output "frontend_pipeline" {
  description = "Frontend pipeline details (null when site is disabled)."
  value = var.enable_s3_frontend ? {
    pipeline_name   = aws_codepipeline.frontend_pipeline[0].name
    artifact_bucket = var.frontend_artifact_bucket
    build_project   = aws_codebuild_project.frontend_build[0].name
    invalidate_job  = aws_codebuild_project.frontend_invalidate_cache[0].name
  } : null
}

output "maintenance_pipeline" {
  description = "Maintenance branch pipeline details."
  value = var.enable_s3_frontend ? {
    name            = aws_codepipeline.maintenance_pipeline[0].name
    artifact_bucket = var.frontend_artifact_bucket
    branch          = var.maintenance_branch
  } : null
}
