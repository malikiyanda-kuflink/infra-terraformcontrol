

# -------------------------------------------------------
# RDS 
# -------------------------------------------------------

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

  # Default parameters + caller overrides
  dynamic "parameter" {
    for_each = local.mysql_parameters
    content {
      name  = parameter.key
      value = parameter.value
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