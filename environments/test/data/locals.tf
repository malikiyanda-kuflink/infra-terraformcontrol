locals {
  env               = "test"
  name_prefix       = "kuflink-test"
  environment       = "Test"
  name_prefix_upper = "Kuflink-Test"
  aws_route53_zone  = "brickfin.co.uk"

  # ------------------------------------------
  # DNS Switch (true)/(false)
  # ------------------------------------------
  active_color      = "green"
  test_active_color = "blue"

  # active_color = "blue"
  # test_active_color = "green"


  # RDS and Redshift toggles
  create_read_replica                      = true
  restore_rds_from_snapshot                = true
  restored_primary_rds_instance_identifier = "kuflink-test"
  new_primary_rds_instance_identifier      = "kuflink-test-mysql"

  enable_redshift                         = false
  restore_redshift_from_snapshot          = true
  restored_redshift_cluster_identifier    = "kuflink-test"
  new_primary_redshift_cluster_identifier = "kuflink-test-redshift"

  # Set this to a non-empty value to perform a restore
  db_snapshot_identifier       = "kuflink-mysql-latest"
  redshift_snapshot_identifier = "kuflink-redshift-latest"
  # dms_access_for_endpoint_arn  = data.terraform_remote_state.foundation.outputs.staging_dms_endpoint_access_arn 

  mysql_port    = 3306
  redshift_port = 5439

  blue_mysql_host    = length(data.aws_db_instance.rds_legacy) > 0 ? data.aws_db_instance.rds_legacy[0].address : "no-${local.env}-rds-instance"
  blue_mysql_ro_host = length(data.aws_db_instance.rds_ro_legacy) > 0 ? data.aws_db_instance.rds_ro_legacy[0].address : "no-${local.env}-rds-replica-instance"


  # Optional: override/add MySQL parameters
  mysql_parameters = {
    log_bin_trust_function_creators = "1"
    binlog_format                   = "ROW"
    binlog_row_image                = "FULL"
    wait_timeout                    = "28800"
    interactive_timeout             = "28800"
    net_read_timeout                = "600"
    net_write_timeout               = "600"
  }
}