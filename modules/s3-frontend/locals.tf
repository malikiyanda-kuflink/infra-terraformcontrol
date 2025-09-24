locals {
  origin_id             = var.enable_s3_frontend ? "${var.name_prefix}-origin" : null
  maintenance_origin_id = var.enable_s3_frontend ? "${var.name_prefix}-frontend-maintenance-origin" : null
}