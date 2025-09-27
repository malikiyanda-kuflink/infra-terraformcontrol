module "secrets" {
  source = "git::ssh://git@github.com/malikiyanda-kuflink/infra-terraformcontrol.git//modules/parameter-store?ref=v0.1.70"
  environment = local.env
}