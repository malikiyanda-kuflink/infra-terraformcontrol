variable "enable_s3_admin" { type = bool }
variable "bucket_force_destroy" { type = bool }
variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "bucket_name" { type = string }
variable "cf_aliases" { type = list(string) }
# variable "maintenance_cf_aliases" { type = list(string) }
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


variable "aws_cli_region" { type = string }
variable "tags" { type = map(string) }

# IAM roles 
variable "admin_codebuild_role_arn" { type = string }
variable "admin_codepipeline_role_arn" { type = string }

# CodeStar + repo
variable "admin_codestar_connection" { type = string }
variable "admin_repo" { type = string } # e.g. "kuflink/kuflink-admin"
variable "admin_branch" { type = string }

# variable "maintenance_branch" { type = string }        # e.g., "maintenance-b"
# variable "maintenance_pipeline_name" { type = string } # e.g., "${var.name_prefix}-admin-maintenance-pipeline"
# variable "maintenance_bucket_name" { type = string }


# Buildspec paths
variable "api_url" { type = string }
variable "admin_website_url" { type = string }
variable "admin_codebuild_email_endpoint" { type = string }
variable "admin_codebuild_image" { type = string }
variable "admin_buildspec_path" { type = string }            # e.g. "${path.module}/buildspec/s3-site-buildspec.yml"
variable "admin_invalidate_buildspec_path" { type = string } # e.g. "${path.module}/buildspec/s3-site-invalidate-buildspec.yml"

# Artifact store and targets
variable "admin_artifact_bucket" { type = string } # S3 bucket for pipeline artifacts
variable "admin_app_bucket" { type = string }      # deploy target bucket (from this module output or passed)
# variable "maintenance_app_bucket" { type = string } # deploy target bucket (from this module output or passed)
variable "admin_cloudfront_id" { type = string } # CF dist ID (from this module output or passed)

# Flip true to route users to the maintenance distribution
variable "serve_frontend_maintenance" {
  type    = bool
  default = false

  description = "Flip true to route traffic to the maintenance origin."
}
variable "s3_region" {
  type    = string
  default = "eu-west-2"
}

variable "cloudfront_zone_id" {
  type = string
}

variable "admin_waf_arn" {
  type = string
}