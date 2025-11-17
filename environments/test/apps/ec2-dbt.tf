# Create SSM parameter with CloudWatch config
resource "aws_ssm_parameter" "dbt_cloudwatch_config" {
  count = local.enable_dbt ? 1 : 0
  name  = "/ec2/dbt/${local.dbt_config.environment}/cloudwatch_config"
  type  = "String"
  value = jsonencode({
    agent = {
      run_as_user          = "root"
      debug                = false
      force_flush_interval = 60
    }
    metrics = {
      namespace = "__NAMESPACE__"
      append_dimensions = {
        InstanceId = "$${aws:InstanceId}"
      }
      aggregation_dimensions = [["InstanceId"]]
      metrics_collected = {
        cpu = {
          measurement = [
            {
              name   = "cpu_usage_idle"
              rename = "cpu_usage_idle"
              unit   = "Percent"
            },
            {
              name   = "cpu_usage_user"
              rename = "cpu_usage_user"
              unit   = "Percent"
            }
          ]
          totalcpu                    = true
          metrics_collection_interval = 60
        }
        mem = {
          measurement = [
            {
              name   = "mem_used_percent"
              rename = "mem_used_percent"
              unit   = "Percent"
            }
          ]
          metrics_collection_interval = 60
        }
        disk = {
          measurement = [
            {
              name   = "disk_used"
              rename = "disk_used"
              unit   = "Gigabytes"
            },
            {
              name   = "disk_free"
              rename = "disk_free"
              unit   = "Gigabytes"
            },
            {
              name   = "disk_total"
              rename = "disk_total"
              unit   = "Gigabytes"
            },
            {
              name   = "disk_used_percent"
              rename = "disk_used_percent"
              unit   = "Percent"
            }
          ]
          resources                   = ["/"]
          ignore_file_system_types    = ["sysfs", "devtmpfs", "tmpfs"]
          metrics_collection_interval = 60
        }
        swap = {
          measurement = [
            {
              name   = "swap_used_percent"
              rename = "swap_used_percent"
              unit   = "Percent"
            }
          ]
          metrics_collection_interval = 60
        }
      }
    }
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/syslog"
              log_group_name  = "/ec2/__INSTANCE_NAME__/syslog"
              log_stream_name = "{instance_id}-syslog"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/cloud-init-output.log"
              log_group_name  = "/ec2/__INSTANCE_NAME__/cloud-init"
              log_stream_name = "{instance_id}-cloud-init-output"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/user-data.log"
              log_group_name  = "/ec2/__INSTANCE_NAME__/user-data"
              log_stream_name = "{instance_id}-user-data"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/kern.log"
              log_group_name  = "/ec2/__INSTANCE_NAME__/kern"
              log_stream_name = "{instance_id}-kern"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/auth.log"
              log_group_name  = "/ec2/__INSTANCE_NAME__/auth"
              log_stream_name = "{instance_id}-auth"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/dbt/dbt.log"
              log_group_name  = "/ec2/__INSTANCE_NAME__/dbt-runtime"
              log_stream_name = "{instance_id}-dbt-runtime"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/dbt/scheduled-runs.log"
              log_group_name  = "/ec2/__INSTANCE_NAME__/dbt-scheduled-runs"
              log_stream_name = "{instance_id}-scheduled-runs"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/dbt/cron.log"
              log_group_name  = "/ec2/__INSTANCE_NAME__/dbt-cron"
              log_stream_name = "{instance_id}-cron"
              timezone        = "UTC"
            }
          ]
        }
      }
    }
  })
  tags = {
    Environment = local.dbt_config.environment
    Name        = "${local.name_prefix}-dbt-cloudwatch-config"
  }
}

module "ec2-dbt" {
  count       = local.enable_dbt ? 1 : 0
  depends_on  = [aws_ssm_parameter.dbt_cloudwatch_config]
  source      = "../../../modules/ec2-dbt"
  name_prefix = local.name_prefix
  environment = local.dbt_config.environment


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

  # Root Block Device Configuration
  root_volume_type                  = local.dbt_config.root_volume_type
  root_volume_size                  = local.dbt_config.root_volume_size
  root_volume_iops                  = local.dbt_config.root_volume_iops
  root_volume_throughput            = local.dbt_config.root_volume_throughput
  root_volume_encrypted             = local.dbt_config.root_volume_encrypted
  root_volume_kms_key_id            = local.dbt_config.root_volume_kms_key_id
  root_volume_delete_on_termination = local.dbt_config.root_volume_delete_on_termination
       

  # Code Deploy Configuration
  code_deploy_project_name    = local.dbt_config.code_deploy_project_name
  codedeploy_service_role_arn = data.terraform_remote_state.foundation.outputs.iam_resources.code_deploy.role_arn

  instance_tags = {  
    DBT-Test-DeploymentTarget = local.dbt_config.code_deploy_project_name
  }

}

