locals {
  # --------------------------------------
  # COMPUTE LAYER CORE CONTROLS
  # Standard environment identifiers and global toggles that control
  # whether EB, Bastion, Redis, and related DNS are created.
  # --------------------------------------
  # Comptue layer locals (controls)
  # --------------------------------------
  # --- Bastion Host toggles --- # flip to true/false to skip creating the stacks
  enable_bastion             = true
  enable_bastion_dns         = true

  # --- API Platform toggles --- # flip to true/false to skip creating the stacks
  enable_eb                  = true
  enable_eb_waf              = true
  enable_redis               = true

  # --- Frontend/Admin S3 toggles --- # flip to true/false to skip creating the stacks
  enable_s3_admin            = true 
  enable_s3_admin_waf        = true
  enable_s3_frontend         = true
  serve_frontend_maintenance = false

  # --- EC2 Site toggles --- # flip to true/false to skip creating the stacks
  enable_dbt                 = true
  enable_metabase            = false
  enable_wordpress           = false
  enable_test_instance       = false
}