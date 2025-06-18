# Reference networking outputs
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/networking/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/shared/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}

# Reference IAM outputs → this is the new part
data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket         = "kuflink-staging-state"
    key            = "staging/iam/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
  }
}


# Call bastion module
module "bastion-terraform" {
  source = "../../../modules/bastion-terraform"

  vpc_id                  = data.terraform_remote_state.networking.outputs.vpc_id
  public_subnet_id        = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
  office_ip_cidr_blocks   = var.office_ip_cidr_blocks
  ssh_key_parameter_name  = var.ssh_key_parameter_name 
  ssh_key_name            = "staging"
  bastion_name            = "Kuflink-Test-Bastion"
} 


module "ec2_test_instance" {
  source              = "../../../modules/ec2-test-terraform"

  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_id   = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
  bastion_sg_id       = module.bastion-terraform.bastion_sg_id
  ssh_key_name        = "staging"
  instance_name       = "Kuflink-Test-Instance"
  # No instance_type → will use default "t2.micro"
  # instance_type       = "t3.micro"  # override the default here
}

module "redis_elastic_cache" {
  source = "../../../modules/redis-elastic-cache"
  vpc_id                       = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids           = data.terraform_remote_state.networking.outputs.private_subnet_ids

  redis_elastic_cache_password = data.terraform_remote_state.shared.outputs.redis_elastic_cache_password
  redis_elastic_cache_port     = data.terraform_remote_state.shared.outputs.redis_elastic_cache_port 

  web_app_sg_id  = module.web_app.web_app_sg_id 
  bastion_sg_id = module.bastion-terraform.bastion_sg_id
}


module "web_app" {
  source = "../../../modules/web-app-terraform"

  environment             = var.environment
  bastion_private_ip      = module.bastion-terraform.bastion_private_id  
  eb_role_arn             = data.terraform_remote_state.iam.outputs.eb_role_arn 
  eb_instance_profile_arn = data.terraform_remote_state.iam.outputs.eb_instance_profile_arn

  # SSL
  ssl_certificate_arn     = var.ssl_certificate_arn

  # Networking
  vpc_id             = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.networking.outputs.public_subnet_ids

  # Redis
  redis_endpoint                = module.redis_elastic_cache.redis_endpoint
  redis_elastic_cache_password = data.terraform_remote_state.shared.outputs.redis_elastic_cache_password
  redis_elastic_cache_php_client = data.terraform_remote_state.shared.outputs.redis_elastic_cache_php_client
  redis_elastic_cache_port       = data.terraform_remote_state.shared.outputs.redis_elastic_cache_port

  # Shared shared & Settings
  app_env                    = data.terraform_remote_state.shared.outputs.app_env
  app_url                    = data.terraform_remote_state.shared.outputs.app_url
  aws_region                 = data.terraform_remote_state.shared.outputs.aws_region
  aws_sqs_prefix             = data.terraform_remote_state.shared.outputs.aws_sqs_prefix
  aws_sqs_driver             = data.terraform_remote_state.shared.outputs.aws_sqs_driver
  broadcast_driver           = data.terraform_remote_state.shared.outputs.broadcast_driver
  cache_driver               = data.terraform_remote_state.shared.outputs.cache_driver
  can_run_schedule           = data.terraform_remote_state.shared.outputs.can_run_schedule
  mandrill_secret            = data.terraform_remote_state.shared.outputs.mandrill_secret
  bank_of_england_api_url    = data.terraform_remote_state.shared.outputs.bank_of_england_api_url
  send_local_emails          = data.terraform_remote_state.shared.outputs.send_local_emails
  get_address_location_key   = data.terraform_remote_state.shared.outputs.get_address_location_key 
  # codepipeline_artifacts_bucket_name = data.terraform_remote_state.shared.outputs.codepipeline_artifacts_bucket_name
  connected_stripe_account_id = data.terraform_remote_state.shared.outputs.connected_stripe_account_id 
  personal_agreement_url     = data.terraform_remote_state.shared.outputs.personal_agreement_url
  corporate_agreement_url    = data.terraform_remote_state.shared.outputs.corporate_agreement_url    
  bank_of_england_api_key    = data.terraform_remote_state.shared.outputs.bank_of_england_api_key 

  # Mangopay
  mangopay_client                                 = data.terraform_remote_state.shared.outputs.mangopay_client
  mangopay_passphrase                             = data.terraform_remote_state.shared.outputs.mangopay_passphrase
  mangopay_redirect_url                           = data.terraform_remote_state.shared.outputs.mangopay_redirect_url
  mangopay_url                                    = data.terraform_remote_state.shared.outputs.mangopay_url
  mangopay_max_funds_per_transaction_for_topup    = data.terraform_remote_state.shared.outputs.mangopay_max_funds_per_transaction_for_topup
  mangopay_topup_funds_limit_without_mangopay_aml = data.terraform_remote_state.shared.outputs.mangopay_topup_funds_limit_without_mangopay_aml

  # Queues
  queue_default         = data.terraform_remote_state.shared.outputs.queue_default
  queue_connection      = data.terraform_remote_state.shared.outputs.queue_connection
  aws_sqs_region        = data.terraform_remote_state.shared.outputs.aws_sqs_region 

  # Sessions & Logging
  session_driver        = data.terraform_remote_state.shared.outputs.session_driver
  session_secure_cookie = data.terraform_remote_state.shared.outputs.session_secure_cookie
  app_log_level         = data.terraform_remote_state.shared.outputs.app_log_level
  app_debug             = data.terraform_remote_state.shared.outputs.app_debug
  composer_home         = data.terraform_remote_state.shared.outputs.composer_home
  telescope_enabled     = data.terraform_remote_state.shared.outputs.telescope_enabled
  activity_logger_enabled       = data.terraform_remote_state.shared.outputs.activity_logger_enabled
  activity_logger_db_connection = data.terraform_remote_state.shared.outputs.activity_logger_db_connection
  log_channel                  = data.terraform_remote_state.shared.outputs.log_channel

  # Email
  mail_driver     = data.terraform_remote_state.shared.outputs.mail_driver
  mail_host       = data.terraform_remote_state.shared.outputs.mail_host
  mail_port       = data.terraform_remote_state.shared.outputs.mail_port
  mail_username   = data.terraform_remote_state.shared.outputs.mail_username
  mail_password   = data.terraform_remote_state.shared.outputs.mail_password
  mail_encryption = data.terraform_remote_state.shared.outputs.mail_encryption
  mandrill_apikey = data.terraform_remote_state.shared.outputs.mandrill_apikey
  ses_key         = data.terraform_remote_state.shared.outputs.ses_key
  ses_secret      = data.terraform_remote_state.shared.outputs.ses_secret
  ses_region      = data.terraform_remote_state.shared.outputs.ses_region

  # Stripe
  stripe_publishable_key = data.terraform_remote_state.shared.outputs.stripe_publishable_key
  stripe_secret_key      = data.terraform_remote_state.shared.outputs.stripe_secret_key

  # Twilio
  twilio_account_sid = data.terraform_remote_state.shared.outputs.twilio_account_sid
  twilio_auth_token  = data.terraform_remote_state.shared.outputs.twilio_auth_token

  # Intercom & Hubspot
  intercom_integration  = data.terraform_remote_state.shared.outputs.intercom_integration
  hubspot_access_token  = data.terraform_remote_state.shared.outputs.hubspot_access_token

  # Docusign
  docusign_account_id    = data.terraform_remote_state.shared.outputs.docusign_account_id
  docusign_client_id     = data.terraform_remote_state.shared.outputs.docusign_client_id
  docusign_client_secret = data.terraform_remote_state.shared.outputs.docusign_client_secret
  docusign_api_url       = data.terraform_remote_state.shared.outputs.docusign_api_url
  docusign_base_url      = data.terraform_remote_state.shared.outputs.docusign_base_url

  # Onfido
  onfido_web_api_key        = data.terraform_remote_state.shared.outputs.onfido_web_api_key
  onfido_mob_api_key        = data.terraform_remote_state.shared.outputs.onfido_mob_api_key
  onfido_mob_application_id = data.terraform_remote_state.shared.outputs.onfido_mob_application_id

  # Database – Test
  db_test_connection         = data.terraform_remote_state.shared.outputs.db_test_connection
  db_test_port               = data.terraform_remote_state.shared.outputs.db_test_port
  db_test_username           = data.terraform_remote_state.shared.outputs.db_test_username
  db_test_password           = data.terraform_remote_state.shared.outputs.db_test_password
  db_test_database           = data.terraform_remote_state.shared.outputs.db_test_database
  db_test_host               = data.terraform_remote_state.shared.outputs.db_test_host
  db_test_subnet_group_name  = data.terraform_remote_state.shared.outputs.db_test_subnet_group_name

  # Database – Audit
  db_port_audit          = data.terraform_remote_state.shared.outputs.db_port_audit
  db_password_audit      = data.terraform_remote_state.shared.outputs.db_password_audit
  db_connection_audit_name = data.terraform_remote_state.shared.outputs.db_connection_audit_name
  db_username_audit      = data.terraform_remote_state.shared.outputs.db_username_audit
  db_host_audit          = data.terraform_remote_state.shared.outputs.db_host_audit
  db_database_audit      = data.terraform_remote_state.shared.outputs.db_database_audit

  # Database – Staging Testing
  db_port_staging_testing     = data.terraform_remote_state.shared.outputs.db_port_staging_testing
  db_host_staging_testing     = data.terraform_remote_state.shared.outputs.db_host_staging_testing
  db_username_staging_testing = data.terraform_remote_state.shared.outputs.db_username_staging_testing
  db_database_staging_testing = data.terraform_remote_state.shared.outputs.db_database_staging_testing

  # Database – Readonly
  db_port_readonly         = data.terraform_remote_state.shared.outputs.db_port_readonly
  db_password_readonly     = data.terraform_remote_state.shared.outputs.db_password_readonly
  db_username_readonly     = data.terraform_remote_state.shared.outputs.db_username_readonly
  db_host_readonly         = data.terraform_remote_state.shared.outputs.db_host_readonly
  db_connection_read_only  = data.terraform_remote_state.shared.outputs.db_connection_read_only
  db_database_readonly     = data.terraform_remote_state.shared.outputs.db_database_readonly

  # Database – Staging
  db_host_staging             = data.terraform_remote_state.shared.outputs.db_host_staging
  db_username_staging         = data.terraform_remote_state.shared.outputs.db_username_staging
  db_password_staging         = data.terraform_remote_state.shared.outputs.db_password_staging
  db_database_staging         = data.terraform_remote_state.shared.outputs.db_database_staging
  db_port_staging             = data.terraform_remote_state.shared.outputs.db_port_staging
  db_connection_staging_name  = data.terraform_remote_state.shared.outputs.db_connection_staging_name

  # Worker
  worker_can_run_schedule           = data.terraform_remote_state.shared.outputs.worker_can_run_schedule
  register_worker_routes            = data.terraform_remote_state.shared.outputs.register_worker_routes
  worker_register_worker_routes     = data.terraform_remote_state.shared.outputs.worker_register_worker_routes

  # shared – General
  app_key               = data.terraform_remote_state.shared.outputs.app_key
  aws_access_key_id     = data.terraform_remote_state.shared.outputs.aws_access_key_id
  aws_secret_access_key = data.terraform_remote_state.shared.outputs.aws_secret_access_key
  aws_default_region    = data.terraform_remote_state.shared.outputs.aws_default_region
  kuflink_codestar_connection = data.terraform_remote_state.shared.outputs.kuflink_codestar_connection
}





