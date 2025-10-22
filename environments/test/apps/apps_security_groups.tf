# Requires: hashicorp/aws >= 5.0
resource "aws_security_group" "eb_web_app_sg" {
  name_prefix = "${local.name_prefix}-api-access"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id

  tags = { Name = "Kuflink-Test-WebAPI-EC2-SG" }
}

resource "aws_security_group" "kuflink_wp_sg" {
  name        = "${local.name_prefix}-wordpress-ec2-sg-access"
  description = "Security group for Kuflink WordPress EC2"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id

  tags = { Name = "Kuflink-Test-Wordpress-EC2-SG" }
}

resource "aws_security_group" "metabase_sg" {
  name_prefix = "${local.name_prefix}-metabase-sg-access"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id

  tags = { Name = "Kuflink-Test-Metabase-EC2-SG" }
}

resource "aws_security_group" "metabase_alb_sg" {
  name        = "kuflink-test-metabase-ec2-alb-sg"
  description = "Security group for Metabase ALB"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id

  tags = { Name = "Kuflink-Test-Metabase-EC2-ALB-SG" }
}

resource "aws_security_group" "test_instance_sg" {
  name_prefix = "kuflinktest-test-instance-access"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id

  tags = { Name = "Kuflink-Test-Instance-EC2-SG" }
}

resource "aws_security_group" "bastion_sg" {
  name_prefix = "${local.name_prefix}-bastion-access"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id

  tags = { Name = "Kuflink-Test-Bastion-EC2-SG" }
}

resource "aws_security_group" "redis_sg" {
  name        = "${local.name_prefix}-redis-sg-access"
  description = "Allow Redis traffic"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  tags = {
    Name         = "Kuflink-Test-Redis-SG"
    Descriptpion = "Redis Security Group for laravel-php-api"
  }
}

resource "aws_security_group" "dbt_sg" {
  name        = "${local.name_prefix}-dbt-access"
  description = "Allow DBT traffic"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  tags = {
    Name         = "Kuflink-Test-DBT-SG"
    Descriptpion = "DBT Security Group"
  }
}

resource "aws_security_group" "dbt_alb_sg" {
  name        = "${local.dbt_config.dbt_name}-ALB-SG"
  description = "Allow DBT traffic"
  vpc_id      = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  tags = {
    Name         = "${local.dbt_config.dbt_name}-ALB-SG"
    Descriptpion = "DBT Load balancer Security Group"
  }
}