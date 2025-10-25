# Create SSM parameter with CloudWatch config
resource "aws_ssm_parameter" "dbt_cloudwatch_config" {
  count = local.enable_dbt ? 1 : 0
  name  = "/kuflink/dbt/${local.environment}/cloudwatch-config"
  type  = "String"
  value = jsonencode({
    agent = {
      run_as_user          = "root"
      debug                = true
      force_flush_interval = 1
    }
    metrics = {
      namespace = "CWAgent-${local.dbt_config.dbt_name}-Limited"
      append_dimensions = {
        InstanceId = "$${aws:InstanceId}"
      }
      metrics_collected = {
        collectd = {
          collectd_security_level = "none"
          collectd_typesdb        = ["/usr/share/collectd/types.db"]
        }
        cpu = {
          measurement                 = ["cpu_usage_idle", "cpu_usage_user"]
          totalcpu                    = true
          metrics_collection_interval = 10
        }
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 10
        }
        disk = {
          measurement                 = ["disk_used", "disk_free", "disk_total", "disk_used_percent"]
          resources                   = ["/"]
          metrics_collection_interval = 10
        }
        swap = {
          measurement                 = ["swap_used_percent"]
          metrics_collection_interval = 10
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/syslog"
              log_group_name  = "/ec2/${local.dbt_config.dbt_name}/syslog"
              log_stream_name = "{instance_id}-syslog"
            },
            {
              file_path       = "/var/log/cloud-init-output.log"
              log_group_name  = "/ec2/${local.dbt_config.dbt_name}/cloud-init"
              log_stream_name = "{instance_id}-cloud-init-output"
            },
            {
              file_path       = "/var/log/user-data.log"
              log_group_name  = "/ec2/${local.dbt_config.dbt_name}/user-data"
              log_stream_name = "{instance_id}-user-data"
            }
          ]
        }
      }
    }
  })

  tags = {
    Environment = local.environment
    Name        = "${local.name_prefix}-dbt-cloudwatch-config"
  }
}

module "ec2-dbt" {
  count       = local.enable_dbt ? 1 : 0
  source      = "../../../modules/ec2-dbt"
  name_prefix = local.name_prefix
  environment = local.environment


  #Monitoring 
  cloudwatch_ops_notification_email = data.terraform_remote_state.foundation.outputs.global.build_notification_email

  # Networking
  vpc_id            = data.terraform_remote_state.foundation.outputs.vpc_resources.vpc.id
  private_subnet_id = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.private_ids[2]
  public_subnet_ids = data.terraform_remote_state.foundation.outputs.vpc_resources.subnets.public_ids

  # Security
  dbt_sg_id                 = aws_security_group.dbt_sg.id
  alb_sg_id                 = aws_security_group.dbt_alb_sg.id
  dbt_instance_profile_name = data.terraform_remote_state.foundation.outputs.iam_resources.dbt.instance_profile_name
  acm_certificate_arn       = data.terraform_remote_state.foundation.outputs.ssl_certificate_arn

  # DNS
  route53_zone_name  = local.aws_route53_zone
  dbt_docs_subdomain = local.dbt_config.dbt_docs_subdomain

  # Instance Configuration
  ssh_key_name  = local.dbt_config.ssh_key_name
  instance_type = local.dbt_config.instance_type
  dbt_user_data = local.dbt_user_data_with_env
  canonical_id  = data.terraform_remote_state.foundation.outputs.global.canonical_id
  dbt_name      = local.dbt_config.dbt_name

  #Code Deploy Configuration
  code_deploy_project_name    = local.dbt_config.code_deploy_project_name
  codedeploy_service_role_arn = data.terraform_remote_state.foundation.outputs.iam_resources.code_deploy.role_arn

  instance_tags = {
    DBT-Test-DeploymentTarget = local.dbt_config.code_deploy_project_name
  }

}

