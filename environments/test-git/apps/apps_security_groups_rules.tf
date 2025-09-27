# ----------------------------
# Bastion inbound (office IPs
# ----------------------------

# Office IPs -> Bastion SSH (22)
resource "aws_vpc_security_group_ingress_rule" "bastion_office_ssh" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr => ip }
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Office SSH"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = each.key
}

# Office IPs -> Bastion Port Forward (9990)
resource "aws_vpc_security_group_ingress_rule" "bastion_office_pf_9990" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr => ip }
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Office PF 9990"
  ip_protocol       = "tcp"
  from_port         = 9990
  to_port           = 9990
  cidr_ipv4         = each.key
}

# NGW IPs -> Bastion (22, 9990)
resource "aws_vpc_security_group_ingress_rule" "bastion_ngw_22" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Prod NGW SSH"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "52.56.33.206/32"
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ngw_9990" {
  security_group_id = aws_security_group.bastion_sg.id
  description       = "Prod NGW PF 9990"
  ip_protocol       = "tcp"
  from_port         = 9990
  to_port           = 9990
  cidr_ipv4         = "52.56.33.206/32"
}

# ---------------------------------------
# Bastion -> other SGs (cross-SG ingress)
# ---------------------------------------
# ----- safe locals -----
locals {
  rds_sg_id      = lookup(data.terraform_remote_state.data.outputs, "rds_security_group_id", null)
  redis_sg_id    = lookup(data.terraform_remote_state.data.outputs, "redis_sg_id", null)
  redshift_sg_id = lookup(data.terraform_remote_state.data.outputs, "redshift_security_group_id", null)
  db_endpoint    = lookup(data.terraform_remote_state.data.outputs, "db_dns_instance_endpoint", null)
}

# ----- rules guarded by existence -----
resource "aws_vpc_security_group_ingress_rule" "allow_bastion_to_rds" {
  count                        = local.rds_sg_id != null ? 1 : 0
  security_group_id            = local.rds_sg_id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  description                  = "Bastion to RDS 3306"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_to_redis_ec2" {
  count                        = local.redis_sg_id != null ? 1 : 0
  security_group_id            = local.redis_sg_id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  description                  = "Bastion to Redis 6379"
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_to_redshift" {
  count                        = local.redshift_sg_id != null ? 1 : 0
  security_group_id            = local.redshift_sg_id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  description                  = "Bastion to Redshift 5439"
  ip_protocol                  = "tcp"
  from_port                    = 5439
  to_port                      = 5439
}

#============================================================
# Redis SG
#============================================================
# Office IPs → SSH (22)
resource "aws_vpc_security_group_ingress_rule" "redis_office_ssh" {
  for_each          = { for ip in data.terraform_remote_state.foundation.outputs.kuflink_office_ips : ip.cidr => ip }
  security_group_id = aws_security_group.redis_sg.id
  description       = each.value.description
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = each.key
}

# Private subnets → Redis (6379)
resource "aws_vpc_security_group_ingress_rule" "redis_private_cidrs" {
  for_each          = toset(data.terraform_remote_state.foundation.outputs.private_subnet_cidrs)
  security_group_id = aws_security_group.redis_sg.id
  description       = "Allow Private Subnet CIDR"
  ip_protocol       = "tcp"
  from_port         = 6379
  to_port           = 6379
  cidr_ipv4         = each.value
}
# ---------------------------------
# App/EC2 SGs inbound dependencies
# ---------------------------------

# Bastion -> EB Web App SSH (22)
resource "aws_vpc_security_group_ingress_rule" "bastion_to_eb_web_app_ssh" {
  security_group_id            = aws_security_group.eb_web_app_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  description                  = "Bastion to WebAPI SSH"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

# Bastion -> WordPress EC2 SSH (22)
resource "aws_vpc_security_group_ingress_rule" "bastion_to_wp_ssh" {
  security_group_id            = aws_security_group.kuflink_wp_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  description                  = "Bastion to WordPress SSH"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

# Bastion -> Test Instance SSH (22)
resource "aws_vpc_security_group_ingress_rule" "bastion_to_test_instance_ssh" {
  security_group_id            = aws_security_group.test_instance_sg.id
  referenced_security_group_id = aws_security_group.bastion_sg.id
  description                  = "Bastion to Test SSH"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

# -------------------------
# Metabase ALB ingress
# -------------------------

# 0.0.0.0/0 -> ALB HTTP (80)
resource "aws_vpc_security_group_ingress_rule" "metabase_alb_http" {
  security_group_id = aws_security_group.metabase_alb_sg.id
  description       = "HTTP 80"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# 0.0.0.0/0 -> ALB HTTPS (443)
resource "aws_vpc_security_group_ingress_rule" "metabase_alb_https" {
  security_group_id = aws_security_group.metabase_alb_sg.id
  description       = "HTTPS 443"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}
