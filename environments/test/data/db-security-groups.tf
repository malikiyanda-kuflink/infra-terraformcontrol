#============================================================
# DBT SG
#============================================================
resource "aws_security_group" "dbt_sg" {
  name_prefix = "${local.name_prefix}-dbt-access"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  tags        = { Name = "Kuflink-Test-DBT-EC2-SG" }
}

#============================================================
# DMS (Deprecated VPC) SG
#============================================================
resource "aws_security_group" "dms_deprecated_vpc_sg" {
  name        = "${local.name_prefix}-dms-deprecated-sg-access"
  description = "DMS SG for default VPC (used by deprecated RDS)"
  vpc_id      = "vpc-ba9facd2"
  tags        = { Name = "Kuflink-Test-DMS-Deprecated-SG" }
}

#============================================================
# DMS (Test VPC) SG
#============================================================
resource "aws_security_group" "dms_vpc_sg" {
  name        = "${local.name_prefix}-dms-sg-access"
  description = "DMS SG for Test VPC"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  tags        = { Name = "Kuflink-Test-DMS-Deprecated-SG" }
}
#============================================================
# RDS (Deprecated VPC) SG
#============================================================
resource "aws_security_group" "rds_deprecated_sg" {
  name        = "${local.name_prefix}-rds-deprecated-access"
  description = "Allow SQL access to RDS (deprecated VPC)"
  vpc_id      = "vpc-ba9facd2"
  tags        = { Name = "Kuflink-Test-RDS-Deprecated-SG" }
}
#============================================================
# RDS SG
#============================================================
resource "aws_security_group" "rds_sg" {
  name        = "${local.name_prefix}-rds-access"
  description = "Allow SQL access to RDS"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  tags        = { Name = "Kuflink-Test-RDS-SG" }
}

#============================================================
# Redis SG
#============================================================
# resource "aws_security_group" "redis_sg" {
#   name        = "${local.name_prefix}-redis-sg-access"
#   description = "Allow Redis traffic"
#   vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
#   tags = {
#     Name         = "Kuflink-Test-Redis-SG"
#     Descriptpion = "Redis Security Group for laravel-php-api"
#   }
# }

#============================================================
# Redshift (Deprecated VPC) SG
#============================================================
resource "aws_security_group" "deprecated_redshift_access" {
  name        = "${local.name_prefix}-deprecated-redshift-access"
  description = "SG for Redshift - trusted IPs only (deprecated VPC)"
  vpc_id      = "vpc-ba9facd2"
  tags        = { Name = "Kuflink-Test-Deprecated-RedShift-SG" }
}

#============================================================
# Redshift SG
#============================================================
resource "aws_security_group" "redshift_access" {
  name        = "${local.name_prefix}-redshift-access"
  description = "Hardened SG for Redshift - trusted IPs only"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  tags        = { Name = "Kuflink-Test-RedShift-SG" }
}