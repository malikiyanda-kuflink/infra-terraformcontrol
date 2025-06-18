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

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "${var.rds_name_tag}-SG-${var.environment}"
  description = "RDS security group"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.rds_allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.rds_name_tag}-SG-${var.environment}"
    Environment = var.environment
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.rds_name_tag}-subnet-group-${var.environment}"
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  tags = {
    Name        = "${var.rds_name_tag}-subnet-group-${var.environment}"
    Environment = var.environment
  }
}



data "aws_route53_zone" "brickfin" {
  name         = "brickfin.co.uk."
  private_zone = false
}

resource "aws_route53_record" "rds_cname" {
  count   = var.restore_from_snapshot ? 1 : 0
  zone_id = data.aws_route53_zone.brickfin.zone_id
  name    = "db.test"
  type    = "CNAME"
  ttl     = 60

  records = [
    replace(
      module.rds_restore[0].db_instance_endpoint,
      "/:[0-9]+$/",
      ""
    )
  ]

}



# RDS Module - new DB create
module "rds" {
  source = "../../../modules/rds"
  count  = var.restore_from_snapshot ? 0 : 1

  db_test_username        = var.db_test_username
  db_test_password        = var.db_test_password
  db_test_database        = var.db_test_database
  db_test_name_identifier = var.db_test_name_identifier

  db_parameter_group_name = var.db_parameter_group_name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  rds_sg_id               = aws_security_group.rds_sg.id

  rds_name_tag                        = var.rds_name_tag
  environment                         = var.environment
  restore_from_snapshot               = var.restore_from_snapshot
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  backup_retention_period             = var.backup_retention_period
  skip_final_snapshot                 = var.skip_final_snapshot
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  publicly_accessible                 = var.publicly_accessible
  deletion_protection                 = var.deletion_protection
  multi_az                            = var.multi_az
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_encrypted                   = var.storage_encrypted
}

# RDS Restore Module - restore from snapshot
module "rds_restore" {
  source = "../../../modules/rds-restored"
  count  = var.restore_from_snapshot && var.db_test_snapshot_identifier != "" ? 1 : 0

  db_test_username            = var.db_test_username
  db_test_password            = var.db_test_password
  db_test_name_identifier     = var.db_test_name_identifier
  db_test_snapshot_identifier = var.db_test_snapshot_identifier

  db_parameter_group_name = var.db_parameter_group_name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  rds_sg_id               = aws_security_group.rds_sg.id

  rds_name_tag                        = var.rds_name_tag
  environment                         = var.environment
  restore_from_snapshot               = var.restore_from_snapshot
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  backup_retention_period             = var.backup_retention_period
  skip_final_snapshot                 = var.skip_final_snapshot
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  publicly_accessible                 = var.publicly_accessible
  deletion_protection                 = var.deletion_protection
  multi_az                            = var.multi_az
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_encrypted                   = var.storage_encrypted
}
