# modules/eb-api/eb-dashboards.tf

locals {
  dashboard_name = "${var.application_name}-${var.environment}-monitoring"
}

resource "aws_cloudwatch_dashboard" "eb_monitoring" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: ALB Request Metrics
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", { stat = "Sum", label = "Total Requests" }],
            ["AWS/ApplicationELB", "RequestCount", { stat = "Sum", label = "Requests/Min", period = 60 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB - Request Volume"
          period  = 300
          yAxis = {
            left = {
              label = "Count"
              showUnits = false
            }
          }
        }
      },
      
      # Row 1: ALB Response Times
      {
        type = "metric"
        x    = 12
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average", label = "Avg Response Time" }],
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "p95", label = "p95 Response Time" }],
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "p99", label = "p99 Response Time" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB - Response Times"
          period  = 300
          yAxis = {
            left = {
              label = "Seconds"
              showUnits = false
            }
          }
        }
      },

      # Row 2: ALB Error Rates
      {
        type = "metric"
        x    = 0
        y    = 6
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", { stat = "Sum", label = "4XX Errors", color = "#FF9900" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", { stat = "Sum", label = "5XX Errors", color = "#D13212" }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", { stat = "Sum", label = "ELB 5XX Errors", color = "#8B0000" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB - Error Counts"
          period  = 300
          yAxis = {
            left = {
              label = "Count"
              showUnits = false
            }
          }
        }
      },

      # Row 2: ALB Active Connections
      {
        type = "metric"
        x    = 8
        y    = 6
        width = 8
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "ActiveConnectionCount", { stat = "Sum", label = "Active Connections" }],
            ["AWS/ApplicationELB", "NewConnectionCount", { stat = "Sum", label = "New Connections" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB - Connection Metrics"
          period  = 300
        }
      },

      # Row 2: Request Rate (requests per minute)
      {
        type = "metric"
        x    = 16
        y    = 6
        width = 8
        height = 6
        properties = {
          metrics = [
            [{ expression = "m1/PERIOD(m1)*60", label = "Requests per Minute", id = "e1", color = "#1f77b4" }],
            ["AWS/ApplicationELB", "RequestCount", { stat = "Sum", id = "m1", visible = false }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Request Rate (per minute)"
          period  = 60
          yAxis = {
            left = {
              label = "Requests/min"
              showUnits = false
            }
          }
        }
      },

      # Row 3: Elastic Beanstalk Environment Health
      {
        type = "metric"
        x    = 0
        y    = 12
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "EnvironmentHealth", "EnvironmentName", var.web_env_name, { stat = "Average", label = "Web Environment Health" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Elastic Beanstalk - Environment Health"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 4
              label = "Health Score"
              showUnits = false
            }
          }
          annotations = {
            horizontal = [
              { label = "Severe", value = 4, fill = "above", color = "#d13212" },
              { label = "Degraded", value = 3, color = "#ff9900" },
              { label = "Warning", value = 2, color = "#ffff00" },
              { label = "Info", value = 1, color = "#1f77b4" },
              { label = "OK", value = 0, fill = "below", color = "#2ca02c" }
            ]
          }
        }
      },

      # Row 3: Instance Health
      {
        type = "metric"
        x    = 12
        y    = 12
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "InstancesOk", "EnvironmentName", var.web_env_name, { stat = "Average", label = "Healthy Instances", color = "#2ca02c" }],
            ["AWS/ElasticBeanstalk", "InstancesDegraded", "EnvironmentName", var.web_env_name, { stat = "Average", label = "Degraded Instances", color = "#ff9900" }],
            ["AWS/ElasticBeanstalk", "InstancesSevere", "EnvironmentName", var.web_env_name, { stat = "Average", label = "Severe Instances", color = "#d13212" }]
          ]
          view    = "timeSeries"
          stacked = true
          region  = var.aws_region
          title   = "Elastic Beanstalk - Instance Health"
          period  = 300
        }
      },

      # Row 4: Application Requests (from EB)
      {
        type = "metric"
        x    = 0
        y    = 18
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "ApplicationRequests2xx", "EnvironmentName", var.web_env_name, { stat = "Sum", label = "2XX Success", color = "#2ca02c" }],
            ["AWS/ElasticBeanstalk", "ApplicationRequests4xx", "EnvironmentName", var.web_env_name, { stat = "Sum", label = "4XX Client Errors", color = "#ff9900" }],
            ["AWS/ElasticBeanstalk", "ApplicationRequests5xx", "EnvironmentName", var.web_env_name, { stat = "Sum", label = "5XX Server Errors", color = "#d13212" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Elastic Beanstalk - Application Response Codes"
          period  = 300
        }
      },

      # Row 4: CPU Utilization
      {
        type = "metric"
        x    = 12
        y    = 18
        width = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "CPUUtilization", "EnvironmentName", var.web_env_name, { stat = "Average", label = "Average CPU" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Elastic Beanstalk - CPU Utilization"
          period  = 300
          yAxis = {
            left = {
              min = 0
              max = 100
              label = "Percent"
              showUnits = false
            }
          }
        }
      }
    ]
  })
}

# Output the dashboard URL for easy access
output "cloudwatch_dashboard_url" {
  description = "URL to access the CloudWatch monitoring dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${local.dashboard_name}"
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.eb_monitoring.dashboard_name
}