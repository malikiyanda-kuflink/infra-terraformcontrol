

# -------------------------------------------------------
# RDS 
# -------------------------------------------------------

# options group 
resource "aws_db_option_group" "kuflink_option_group" {
  name                     = "${local.name_prefix}-mysql-option-group"
  option_group_description = "${local.name_prefix} MySQL 8.0 option group with audit plugin"
  engine_name              = "mysql"
  major_engine_version     = "8.0"

  # option {
  #   option_name = "MARIADB_AUDIT_PLUGIN"

  #   option_settings {
  #     name  = "SERVER_AUDIT_EVENTS"
  #     value = "CONNECT,QUERY"
  #   }

  #   option_settings {
  #     name  = "SERVER_AUDIT_FILE_PATH"
  #     value = "/rdsdbdata/log/audit/"
  #   }

  #   option_settings {
  #     name  = "SERVER_AUDIT_QUERY_LOG_LIMIT"
  #     value = "1024"
  #   }

  #   option_settings {
  #     name  = "SERVER_AUDIT"
  #     value = "FORCE_PLUS_PERMANENT"
  #   }

  #   # option_settings {
  #   #   name  = "SERVER_AUDIT_LOGGING"
  #   #   value = "ON"
  #   # }

  #   option_settings {
  #     name  = "SERVER_AUDIT_EXCL_USERS"
  #     value = ""
  #   }

  #   option_settings {
  #     name  = "SERVER_AUDIT_INCL_USERS"
  #     value = ""
  #   }

  #   option_settings {
  #     name  = "SERVER_AUDIT_FILE_ROTATE_SIZE"
  #     value = ""
  #   }

  #   option_settings {
  #     name  = "SERVER_AUDIT_FILE_ROTATIONS"
  #     value = ""
  #   }
  # }

  tags = {
    Name = "${local.name_prefix}-option-group"
  }
}

# Subnet Group
resource "aws_db_subnet_group" "kuflink_db_subnet_group" {
  name       = "${local.name_prefix}-private-subnet-group"
  subnet_ids = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.private_ids

  tags = { Name = "${local.name_prefix}-private-subnet-group" }
}

# Parameter Group (MySQL 8)
resource "aws_db_parameter_group" "kuflink_parameter_group" {
  name        = "${local.name_prefix}-mysql-parameter-group"
  family      = "mysql8.0"
  description = "${local.name_prefix}-mysql-parameter-group"

  dynamic "parameter" {
    for_each = local.mysql_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = {
    Name = "${local.name_prefix}-parameter-group"
  }
}

# -------------------------------------------------------
# Redshift 
# -------------------------------------------------------

resource "aws_redshift_subnet_group" "kuflink_redshift_subnet_group" {
  name        = "${local.name_prefix}-private-redshift-subnet-group"
  description = "Private subnet group for Redshift cluster"
  subnet_ids  = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.private_ids

  tags = {
    Name = "${local.name_prefix}-redshift-subnet-group"
  }
}


resource "aws_redshift_parameter_group" "kuflink_redshift_pg" {
  name        = "${local.name_prefix}-redshift-parameter-group"
  family      = "redshift-2.0"
  description = "Enable SSL for Redshift cluster"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  tags = { Name = "${local.name_prefix}-redshift-parameter-group" }
}


# -------------------------------------------------------
# DMS 
# -------------------------------------------------------
resource "aws_dms_replication_subnet_group" "dms_subnet_group" {
  count                                = local.enable_redshift ? 1 : 0
  replication_subnet_group_id          = "dms-${local.name_prefix}-subnet-group"
  replication_subnet_group_description = "Subnet group for private DMS replication"
  subnet_ids                           = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.private_ids

  tags = {
    Name = "${local.name_prefix} DMS Subnet Group"
  }
}