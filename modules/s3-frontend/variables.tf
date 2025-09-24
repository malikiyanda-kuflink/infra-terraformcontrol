variable "enable_s3_frontend" { type = bool }
variable "bucket_force_destroy" { type = bool }
variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "bucket_name" { type = string }
variable "cf_aliases" { type = list(string) }
variable "cf_cert_arn" { type = string }
variable "default_ttl_seconds" { type = number }
variable "min_ttl_seconds" { type = number }
variable "hosted_zone_id" { type = string }
variable "hosted_zone_name" { type = string }
variable "record_name" { type = string }
variable "record_ttl" { type = number }
variable "enable_pre_delete_cleanup" { type = bool }
variable "enable_bucket_cleanup_on_destroy" { type = bool }
variable "bucket_prevent_destroy" { type = bool }
variable "aws_cli_profile" { type = string }

variable "aws_cli_region" { type = string }
variable "tags" { type = map(string) }

# IAM roles 
variable "frontend_codebuild_role_arn" { type = string }
variable "frontend_codepipeline_role_arn" { type = string }

# CodeStar + repo
variable "frontend_codestar_connection" { type = string }
variable "frontend_repo" { type = string } # e.g. "kuflink/kuflink-frontend"
variable "frontend_branch" { type = string }

variable "maintenance_branch" { type = string }        # e.g., "maintenance-b"
variable "maintenance_pipeline_name" { type = string } # e.g., "${var.name_prefix}-frontend-maintenance-pipeline"
variable "maintenance_bucket_name" { type = string }


# Buildspec paths
variable "api_url" { type = string }
variable "frontend_codebuild_email_endpoint" { type = string }
variable "frontend_codebuild_image" { type = string }
variable "frontend_buildspec_path" { type = string }            # e.g. "${path.module}/buildspec/s3-site-buildspec.yml"
variable "frontend_invalidate_buildspec_path" { type = string } # e.g. "${path.module}/buildspec/s3-site-invalidate-buildspec.yml"

# Artifact store and targets
variable "frontend_artifact_bucket" { type = string } # S3 bucket for pipeline artifacts
variable "frontend_app_bucket" { type = string }      # deploy target bucket (from this module output or passed)
variable "maintenance_app_bucket" { type = string }   # deploy target bucket (from this module output or passed)
variable "frontend_cloudfront_id" { type = string }   # CF dist ID (from this module output or passed)

# Flip true to route users to the maintenance distribution
variable "serve_frontend_maintenance" {
  type        = bool
  description = "Flip true to route traffic to the maintenance origin."
}

variable "s3_region" {
  type    = string
  default = "eu-west-2"
}

variable "cloudfront_zone_id" {
  type = string
}


