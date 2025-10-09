module "s3-admin" {
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/s3-admin?ref=v0.1.94"

  providers = {
    aws.use1 = aws.use1
  }

  admin_waf_arn = local.admin_waf_arn

  # --- Feature toggles --- 
  serve_frontend_maintenance = local.serve_frontend_maintenance
  enable_s3_admin            = local.enable_s3_admin

  # --- Naming / environment ---
  name_prefix = local.name_prefix_upper
  environment = local.env

  # --- CloudFront / routing ---
  cloudfront_zone_id = local.cloudfront_zone_id
  cf_aliases         = local.admin_domains
  cf_cert_arn        = local.admin_cf_cert_arn

  # --- Buckets ---
  bucket_name = local.admin_bucket_name
  #   maintenance_bucket_name = local.maintenance_bucket_name

  # --- Caching (SPA: zero-cache) ---
  default_ttl_seconds = 0
  min_ttl_seconds     = 0

  # --- DNS ---
  hosted_zone_id   = local.admin_hosted_zone_id
  hosted_zone_name = local.admin_hosted_zone_name
  record_name      = local.admin_record_name
  record_ttl       = 300

  # --- Cleanup knobs ---
  bucket_force_destroy             = true
  enable_pre_delete_cleanup        = false
  enable_bucket_cleanup_on_destroy = false
  bucket_prevent_destroy           = false
  aws_cli_region                   = local.aws_cli_region

  # --- CI/CD pipeline inputs ---
  admin_codebuild_role_arn    = data.terraform_remote_state.foundation.outputs.s3_admin_codebuild_role_arn
  admin_codepipeline_role_arn = data.terraform_remote_state.foundation.outputs.s3_admin_codepipeline_role_arn
  admin_codestar_connection   = local.admin_codestar_connection
  admin_repo                  = local.admin_repo
  admin_branch                = local.admin_branch
  admin_artifact_bucket       = "${local.name_prefix}-admin-pipeline-artifacts"

  # --- Build configuration ---
  api_url                         = local.admin_api_url
  admin_website_url               = local.admin_website_url
  admin_codebuild_image           = local.admin_codebuild_image
  admin_codebuild_email_endpoint  = local.admin_codebuild_email_endpoint
  admin_buildspec_path            = "${path.root}/admin-buildspec-v3/s3-site-buildspec.yml"
  admin_invalidate_buildspec_path = "${path.root}/admin-buildspec-v3/s3-site-invalidate-buildspec.yml"

  # --- Self references / outputs---
  admin_app_bucket    = module.s3-admin.bucket_name
  admin_cloudfront_id = module.s3-admin.cloudfront_id


  # --- Tags ---
  tags = local.tags
}