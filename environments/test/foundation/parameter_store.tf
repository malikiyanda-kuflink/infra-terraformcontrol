module "secrets" {
  source      = "../../../modules/parameter-store"
  environment = local.env
}