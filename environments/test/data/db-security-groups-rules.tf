
#============================================================
# DBT SG
#============================================================
# Office IPs → SSH (22)
resource "aws_vpc_security_group_ingress_rule" "dbt_office_ssh" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr => ip }
  security_group_id = aws_security_group.dbt_sg.id
  description       = each.value.description
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = each.key
}
#===========================================================
# RDS SG
#============================================================
# Office IPs → MySQL (3306)
resource "aws_vpc_security_group_ingress_rule" "rds_office_mysql" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr => ip }
  security_group_id = aws_security_group.rds_sg.id
  description       = each.value.description
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = each.key
}

# Private subnets → MySQL (3306)
resource "aws_vpc_security_group_ingress_rule" "rds_private_mysql" {
  for_each          = toset(data.terraform_remote_state.foundation.outputs.private_subnet_cidrs)
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow Private Subnet CIDR"
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = each.value
}


# Office CIDR → 3306
resource "aws_vpc_security_group_ingress_rule" "rds_office_cidr" {
  for_each          = toset(data.terraform_remote_state.foundation.outputs.kuflink_office_cidr)
  security_group_id = aws_security_group.rds_sg.id
  description       = "Allow Office CIDR"
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = each.value
}
#============================================================
# Redshift (Deprecated VPC) SG
#============================================================
resource "aws_vpc_security_group_ingress_rule" "deprecated_redshift_office" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr => ip }
  security_group_id = aws_security_group.deprecated_redshift_access.id
  description       = each.value.description
  ip_protocol       = "tcp"
  from_port         = 5439
  to_port           = 5439
  cidr_ipv4         = each.key
}
#============================================================
# Redshift SG
#============================================================
# Office IPs → 5439
resource "aws_vpc_security_group_ingress_rule" "redshift_office" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr => ip }
  security_group_id = aws_security_group.redshift_access.id
  description       = each.value.description
  ip_protocol       = "tcp"
  from_port         = 5439
  to_port           = 5439
  cidr_ipv4         = each.key
}

# Private subnets → 5439
resource "aws_vpc_security_group_ingress_rule" "redshift_private_cidrs" {
  for_each          = toset(data.terraform_remote_state.foundation.outputs.private_subnet_cidrs)
  security_group_id = aws_security_group.redshift_access.id
  description       = "Allow Private Subnet CIDR"
  ip_protocol       = "tcp"
  from_port         = 5439
  to_port           = 5439
  cidr_ipv4         = each.value
}


# Fivetran IPs → 5439
resource "aws_vpc_security_group_ingress_rule" "redshift_fivetran" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.fivetran_gcp_ips : ip.cidr => ip }
  security_group_id = aws_security_group.redshift_access.id
  description       = each.value.description
  ip_protocol       = "tcp"
  from_port         = 5439
  to_port           = 5439
  cidr_ipv4         = each.key
}

# dbt Cloud IPs → 5439
resource "aws_vpc_security_group_ingress_rule" "redshift_dbt_cloud" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.dbt_cloud_ips : ip.cidr => ip }
  security_group_id = aws_security_group.redshift_access.id
  description       = each.value.description
  ip_protocol       = "tcp"
  from_port         = 5439
  to_port           = 5439
  cidr_ipv4         = each.key
}

# DMS SG → 5439
resource "aws_vpc_security_group_ingress_rule" "redshift_from_dms_sg" {
  security_group_id            = aws_security_group.redshift_access.id
  referenced_security_group_id = aws_security_group.dms_vpc_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5439
  to_port                      = 5439
  description                  = "DMS SG to Redshift"
}

# DBT SG → 5439
resource "aws_vpc_security_group_ingress_rule" "redshift_from_dbt_sg" {
  security_group_id            = aws_security_group.redshift_access.id
  referenced_security_group_id = aws_security_group.dbt_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5439
  to_port                      = 5439
  description                  = "DBT SG to Redshift"
}


# ===============================
# OUTBOUND RULES FOR DATA LAYER SGs
# ===============================

# DBT SG outbound
resource "aws_vpc_security_group_egress_rule" "dbt_outbound_all" {
  security_group_id = aws_security_group.dbt_sg.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# DMS (Deprecated VPC) SG outbound
resource "aws_vpc_security_group_egress_rule" "dms_deprecated_outbound_all" {
  security_group_id = aws_security_group.dms_deprecated_vpc_sg.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# DMS (Test VPC) SG outbound
resource "aws_vpc_security_group_egress_rule" "dms_vpc_outbound_all" {
  security_group_id = aws_security_group.dms_vpc_sg.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# RDS (Deprecated VPC) SG outbound
resource "aws_vpc_security_group_egress_rule" "rds_deprecated_outbound_all" {
  security_group_id = aws_security_group.rds_deprecated_sg.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# RDS SG outbound
resource "aws_vpc_security_group_egress_rule" "rds_outbound_all" {
  security_group_id = aws_security_group.rds_sg.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Redshift (Deprecated VPC) SG outbound
resource "aws_vpc_security_group_egress_rule" "redshift_deprecated_outbound_all" {
  security_group_id = aws_security_group.deprecated_redshift_access.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Redshift SG outbound
resource "aws_vpc_security_group_egress_rule" "redshift_outbound_all" {
  security_group_id = aws_security_group.redshift_access.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}