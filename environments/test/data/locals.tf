locals {
  env               = "test"
  name_prefix       = "kuflink-test"
  environment       = "Test"
  name_prefix_upper = "Kuflink-Test"
  aws_route53_zone  = data.terraform_remote_state.foundation.outputs.route53_zone_name

  # ------------------------------------------
  # DNS Switch (true)/(false)
  # ------------------------------------------
  active_color      = "green"
  test_active_color = "blue"

  # active_color = "blue"
  # test_active_color = "green"


  # RDS and Redshift toggles
  create_read_replica                      = false
  restore_rds_from_snapshot                = true
  restored_primary_rds_instance_identifier = "kuflink-test"
  new_primary_rds_instance_identifier      = "kuflink-test-mysql"

  enable_redshift                         = true
  restore_redshift_from_snapshot          = true
  restored_redshift_cluster_identifier    = "kuflink-test"
  new_primary_redshift_cluster_identifier = "kuflink-test-redshift"

  # Set this to a non-empty value to perform a restore
  db_snapshot_identifier       = "kuflink-mysql-latest"
  redshift_snapshot_identifier = "kuflink-redshift-latest"
  mysql_port                   = 3306
  redshift_port                = 5439

  blue_mysql_host    = length(data.aws_db_instance.rds_legacy) > 0 ? data.aws_db_instance.rds_legacy[0].address : "no-${local.env}-rds-instance"
  blue_mysql_ro_host = length(data.aws_db_instance.rds_ro_legacy) > 0 ? data.aws_db_instance.rds_ro_legacy[0].address : "no-${local.env}-rds-replica-instance"

  mysql_parameters = {
    general_log = {
      name         = "general_log"
      value        = "1"
      apply_method = "immediate"
    }
    slow_query_log = {
      name         = "slow_query_log"
      value        = "1"
      apply_method = "immediate"
    }
    log_output = {
      name         = "log_output"
      value        = "FILE"
      apply_method = "immediate"
    }
    long_query_time = {
      name         = "long_query_time"
      value        = "2" # CHANGED: Lower from 5 to 2 seconds to catch more slow queries
      apply_method = "immediate"
    }
    innodb_lock_wait_timeout = {
      name         = "innodb_lock_wait_timeout"
      value        = "50"
      apply_method = "immediate"
    }
    innodb_dedicated_server = {
      name         = "innodb_dedicated_server"
      value        = "1"
      apply_method = "pending-reboot"
    }
    innodb_redo_log_capacity = {
      name         = "innodb_redo_log_capacity"
      value        = "2147483648"
      apply_method = "immediate"
    }

    # Keep sort/join buffers
    sort_buffer_size = {
      name         = "sort_buffer_size"
      value        = "4194304" # 4 MB
      apply_method = "immediate"
    }
    join_buffer_size = {
      name         = "join_buffer_size"
      value        = "4194304" # 4 MB
      apply_method = "immediate"
    }

    tmp_table_size = {
      name         = "tmp_table_size"
      value        = "536870912" # 512 MB
      apply_method = "immediate"
    }
    max_heap_table_size = {
      name         = "max_heap_table_size"
      value        = "536870912" # 512 MB
      apply_method = "immediate"
    }

    # Adjust connection memory
    read_buffer_size = {
      name         = "read_buffer_size"
      value        = "1048576" # Reduce to 1 MB (was 2 MB)
      apply_method = "immediate"
    }
    read_rnd_buffer_size = {
      name         = "read_rnd_buffer_size"
      value        = "4194304" # NEW: 4 MB
      apply_method = "immediate"
    }

    # CRITICAL: Reduce max_connections
    max_connections = {
      name         = "max_connections"
      value        = "200" # NEW: Fixed value instead of formula
      apply_method = "immediate"
    }

    log_bin_trust_function_creators = {
      name         = "log_bin_trust_function_creators"
      value        = "1"
      apply_method = "immediate"
    }
    binlog_format = {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "immediate"
    }
    binlog_row_image = {
      name         = "binlog_row_image"
      value        = "FULL"
      apply_method = "immediate"
    }
    wait_timeout = {
      name         = "wait_timeout"
      value        = "28800"
      apply_method = "immediate"
    }
    interactive_timeout = {
      name         = "interactive_timeout"
      value        = "28800"
      apply_method = "immediate"
    }
    net_read_timeout = {
      name         = "net_read_timeout"
      value        = "30"
      apply_method = "immediate"
    }
    net_write_timeout = {
      name         = "net_write_timeout"
      value        = "60"
      apply_method = "immediate"
    }
  }


  # mysql_parameters = {
  #   general_log = {
  #     name         = "general_log"
  #     value        = "1"
  #     apply_method = "immediate"
  #   }
  #   slow_query_log = {
  #     name         = "slow_query_log"
  #     value        = "1"
  #     apply_method = "immediate"
  #   }
  #   log_output = {
  #     name         = "log_output"
  #     value        = "FILE"
  #     apply_method = "immediate"
  #   }
  #   long_query_time = {
  #     name         = "long_query_time"
  #     value        = "5"
  #     apply_method = "immediate"
  #   }
  #   innodb_lock_wait_timeout = {
  #     name         = "innodb_lock_wait_timeout"
  #     value        = "50"
  #     apply_method = "immediate"
  #   }
  #   innodb_dedicated_server = {
  #     name         = "innodb_dedicated_server"
  #     value        = "1"
  #     apply_method = "pending-reboot" # STATIC
  #   }
  #   # innodb_buffer_pool_size = {
  #   #   name         = "innodb_buffer_pool_size"
  #   #   value        = "13958643712"
  #   #   apply_method = "immediate"
  #   # }
  #   # innodb_buffer_pool_instances = {
  #   #   name         = "innodb_buffer_pool_instances"
  #   #   value        = "8"
  #   #   apply_method = "pending-reboot" # STATIC
  #   # }
  #   innodb_redo_log_capacity = {
  #     name         = "innodb_redo_log_capacity"
  #     value        = "2147483648"
  #     apply_method = "immediate"
  #   }
  #   tmp_table_size = {
  #     name         = "tmp_table_size"
  #     value        = "134217728"
  #     apply_method = "immediate"
  #   }
  #   max_heap_table_size = {
  #     name         = "max_heap_table_size"
  #     value        = "134217728"
  #     apply_method = "immediate"
  #   }
  #   sort_buffer_size = {
  #     name         = "sort_buffer_size"
  #     value        = "4194304"
  #     apply_method = "immediate"
  #   }
  #   join_buffer_size = {
  #     name         = "join_buffer_size"
  #     value        = "4194304"
  #     apply_method = "immediate"
  #   }
  #   log_bin_trust_function_creators = {
  #     name         = "log_bin_trust_function_creators"
  #     value        = "1"
  #     apply_method = "immediate"
  #   }
  #   binlog_format = {
  #     name         = "binlog_format"
  #     value        = "ROW"
  #     apply_method = "immediate"
  #   }
  #   binlog_row_image = {
  #     name         = "binlog_row_image"
  #     value        = "FULL"
  #     apply_method = "immediate"
  #   }
  #   wait_timeout = {
  #     name         = "wait_timeout"
  #     value        = "28800"
  #     apply_method = "immediate"
  #   }
  #   interactive_timeout = {
  #     name         = "interactive_timeout"
  #     value        = "28800"
  #     apply_method = "immediate"
  #   }
  #   net_read_timeout = {
  #     name         = "net_read_timeout"
  #     value        = "30"
  #     apply_method = "immediate"
  #   }
  #   net_write_timeout = {
  #     name         = "net_write_timeout"
  #     value        = "60"
  #     apply_method = "immediate"
  #   }
  # }

  # Optional: override/add MySQL parameters
  #  mysql_parameters = {
  # Logging settings
  general_log     = "1"
  slow_query_log  = "1"
  log_output      = "FILE"
  long_query_time = "5"

  # InnoDB settings
  innodb_lock_wait_timeout = "50"
  innodb_dedicated_server  = "1" # NEW - requires reboot
  # innodb_buffer_pool_size      = "13958643712" # NEW - 13 GB    # sys default - {DBInstanceClassMemory*3/4}
  # innodb_buffer_pool_instances = "8"           # NEW - requires reboot # Defaults to 8 
  # innodb_redo_log_capacity     = "2147483648"  # NEW - 2 GB          # Defaults to 2GB

  # Temporary table & sort settings
  tmp_table_size      = "134217728" # NEW - 128 MB
  max_heap_table_size = "134217728" # NEW - 128 MB
  sort_buffer_size    = "4194304"   # NEW - 4 MB
  join_buffer_size    = "4194304"   # NEW - 4 MB

  # Replication settings
  log_bin_trust_function_creators = "1"

  binlog_format       = "ROW"
  binlog_row_image    = "FULL"
  wait_timeout        = "28800"
  interactive_timeout = "28800"
  net_read_timeout    = "30"
  net_write_timeout   = "60"
}


#   mysql_parameters = {
#     # Logging settings
#     general_log     = "1"
#     slow_query_log  = "1"
#     log_output      = "FILE"
#     long_query_time = "5"

#     # InnoDB settings
#     innodb_lock_wait_timeout = "50"

#     # Replication settingsfcxzz\
#     log_bin_trust_function_creators = "1"

#     binlog_format       = "ROW"
#     binlog_row_image    = "FULL"
#     wait_timeout        = "28800"
#     interactive_timeout = "28800"
#     net_read_timeout    = "30"
#     net_write_timeout   = "60"
#   }
# }