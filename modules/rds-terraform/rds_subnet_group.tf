resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.rds_name_tag}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.rds_name_tag}-subnet-group"
    Environment = var.environment
  }
}
