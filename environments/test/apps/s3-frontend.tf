module "s3-frontend" {
  source = "../../../modules/s3-frontend"

  # --- Feature toggles ---
  serve_frontend_maintenance = local.serve_frontend_maintenance
  enable_s3_frontend         = local.enable_s3_frontend

  # --- Naming / environment ---
  name_prefix = local.name_prefix_upper
  environment = local.env

  # --- CloudFront / routing ---
  cloudfront_zone_id = local.cloudfront_zone_id
  cf_aliases         = local.frontend_domains
  cf_cert_arn        = local.frontend_cf_cert_arn

  # --- Buckets ---
  bucket_name             = local.frontend_bucket_name
  maintenance_bucket_name = local.maintenance_bucket_name

  # --- Caching (SPA: zero-cache) ---
  default_ttl_seconds = 0
  min_ttl_seconds     = 0

  # --- DNS ---
  hosted_zone_id   = local.frontend_hosted_zone_id
  hosted_zone_name = local.frontend_hosted_zone_name
  record_name      = local.frontend_record_name
  record_ttl       = 300

  # --- Cleanup knobs ---
  bucket_force_destroy             = true
  enable_pre_delete_cleanup        = false
  enable_bucket_cleanup_on_destroy = false
  bucket_prevent_destroy           = false
  aws_cli_region                   = local.aws_cli_region

  # --- CI/CD pipeline inputs ---
  frontend_codebuild_role_arn    = data.terraform_remote_state.foundation.outputs.s3_frontend_codebuild_role_arn
  frontend_codepipeline_role_arn = data.terraform_remote_state.foundation.outputs.s3_frontend_codepipeline_role_arn
  frontend_codestar_connection   = local.frontend_codestar_connection
  frontend_repo                  = local.frontend_repo
  frontend_branch                = local.frontend_branch
  frontend_artifact_bucket       = "${local.name_prefix}-invest-pipeline-artifacts"

  # --- Build configuration ---
  api_url                            = local.api_url
  frontend_codebuild_image           = local.frontend_codebuild_image
  frontend_codebuild_email_endpoint  = local.frontend_codebuild_email_endpoint
  frontend_buildspec_path            = "${path.root}/frontend-buildspec/s3-site-buildspec.yml"
  frontend_invalidate_buildspec_path = "${path.root}/frontend-buildspec/s3-site-invalidate-buildspec.yml"

  # --- Self references / outputs (kept as-is) ---
  frontend_app_bucket    = module.s3-frontend.bucket_name
  maintenance_app_bucket = module.s3-frontend.maintenance_bucket_name
  frontend_cloudfront_id = module.s3-frontend.cloudfront_id

  # --- Maintenance specifics ---
  maintenance_pipeline_name = "${local.name_prefix_upper}-frontend-maintenance-pipeline"
  maintenance_branch        = "maintenance-b"

  # --- Tags ---
  tags = local.tags
}