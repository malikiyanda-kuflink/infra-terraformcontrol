# modules/eb-api/eb-dashboards.tf

# =============================================================================
# CloudWatch Dashboard for Elastic Beanstalk API Rate Limiting Monitoring
# =============================================================================
# This dashboard provides a comprehensive view of:
# - Application Load Balancer (ALB) metrics - RIGHT SIDE
# - Elastic Beanstalk (EB) environment health - LEFT SIDE
# - Request rates, errors, response times, and connection metrics
# =============================================================================
locals {
  dashboard_name = "${var.application_name}-API-Rate-Limiting-Monitoring-Dashboard"

  # From ARN → "app/<name>/<id>"
  alb_dimension          = try(regex("app/.+$", var.web_alb_arn), "")
  target_group_dimension = local.primary_tg_dimension
}

resource "aws_cloudwatch_dashboard" "eb_monitoring" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      # =========================================================================
      # HEADER: Dashboard Title and Description
      # =========================================================================
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2
        properties = {
          markdown = <<-EOT
            # API Rate Limiting & Performance Monitoring Dashboard

            **Environment:** ${var.web_env_name} | **Region:** ${var.aws_region} | **Load Balancer:** ${local.alb_dimension}

            This dashboard monitors application health, request patterns, and performance metrics critical for implementing rate limiting. Use this to establish baseline traffic patterns before enabling WAF rate limiting rules.
          EOT
        }
      },

      # =========================================================================
      # NEW TOP NUMBERS (height >= 3) — now filtered by TargetGroup + LoadBalancer
      # =========================================================================
      # Widget 1: Healthy Targets - FIXED
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 3
        properties = {
          metrics = local.target_group_dimension != "" && local.alb_dimension != "" ? [
            ["AWS/ApplicationELB", "HealthyHostCount",
              "TargetGroup", local.target_group_dimension,
              "LoadBalancer", local.alb_dimension,
              { stat = "Average", label = "Healthy Targets" }
            ]
            ] : [
            # MUST have same structure - 7 elements
            ["AWS/ApplicationELB", "HealthyHostCount",
              "TargetGroup", "targetgroup/placeholder/0000000000000000",
              "LoadBalancer", "app/placeholder/0000000000000000",
              { stat = "Average", label = "Healthy Targets (Initializing)" }
            ]
          ]
          view                 = "singleValue"
          region               = var.aws_region
          title                = "Healthy Targets"
          setPeriodToTimeRange = true
        }
      },

      # Widget 2: Unhealthy Targets - FIXED
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 3
        properties = {
          metrics = local.target_group_dimension != "" && local.alb_dimension != "" ? [
            ["AWS/ApplicationELB", "UnHealthyHostCount",
              "TargetGroup", local.target_group_dimension,
              "LoadBalancer", local.alb_dimension,
              { stat = "Average", label = "Unhealthy Targets" }
            ]
            ] : [
            # MUST have same structure - 7 elements
            ["AWS/ApplicationELB", "UnHealthyHostCount",
              "TargetGroup", "targetgroup/placeholder/0000000000000000",
              "LoadBalancer", "app/placeholder/0000000000000000",
              { stat = "Average", label = "Unhealthy Targets (Initializing)" }
            ]
          ]
          view                 = "singleValue"
          region               = var.aws_region
          title                = "Unhealthy Targets"
          setPeriodToTimeRange = true
        }
      },

      # =========================================================================
      # ROW 1 HEADER: Environment Health & Traffic Volume
      # =========================================================================
      {
        type   = "text"
        x      = 0
        y      = 5
        width  = 24
        height = 1
        properties = {
          markdown = "## 📊 Row 1: Environment Health & Traffic Volume"
        }
      },

      # Widget 1 (LEFT): Elastic Beanstalk Environment Health Score
      {
        type   = "metric"
        x      = 0
        y      = 9
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ElasticBeanstalk", "EnvironmentHealth", "EnvironmentName", var.web_env_name, {
              stat  = "Average",
              label = "Environment Health Score"
            }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "1. EB Environment Health"
          period  = 300
          yAxis = {
            left = {
              min       = 0
              max       = 4
              label     = "Health Score"
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

      # Widget 2 (RIGHT): ALB Total Request Volume
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 3
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Total Requests in Selected Period"
            }]
          ]
          view                 = "singleValue"
          region               = var.aws_region
          title                = "Total Requests (Selected Time Range)"
          setPeriodToTimeRange = true
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 9
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Total Requests (5 min)"
            }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "2. ALB Request Volume"
          period  = 300
          yAxis = {
            left = {
              label     = "Request Count"
              showUnits = false
            }
          }
        }
      },

      # Widget Notes for Row 1
      {
        type   = "text"
        x      = 0
        y      = 15
        width  = 12
        height = 2
        properties = {
          markdown = <<-EOT
            **Widget 1 Notes:** Overall application health from Elastic Beanstalk. A score of 0 (green) = OK, 4 (red) = Severe issues. Track this for early warning of application or infrastructure degradation.
          EOT
        }
      },
      {
        type   = "text"
        x      = 12
        y      = 15
        width  = 12
        height = 2
        properties = {
          markdown = <<-EOT
            **Widget 2 Notes:** Total HTTP requests hitting your load balancer every 5 minutes. Use this to identify traffic spikes and understand peak usage periods—critical input when choosing WAF rate limits.
          EOT
        }
      },

      # =========================================================================
      # ROW 2 HEADER: Request Rate & Response Performance
      # =========================================================================
      {
        type   = "text"
        x      = 0
        y      = 17
        width  = 24
        height = 1
        properties = {
          markdown = "## ⚡ Row 2: Request Rate & Response Performance"
        }
      },

      # Widget 3A: Request Rate Statistics (Max/Avg/Min) - 3 number widgets

      # Max Request Rate (CRITICAL for WAF rate limit planning)
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 4
        height = 3
        properties = {
          metrics = [
            [{
              expression = "m1/PERIOD(m1)*60",
              label      = "Peak Rate",
              id         = "e1"
            }],
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_dimension, {
              stat    = "Maximum",
              id      = "m1",
              visible = false
            }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Peak req/min"
          period = 60
        }
      },

      # Max explanation
      {
        type   = "text"
        x      = 0
        y      = 20
        width  = 4
        height = 1
        properties = {
          markdown = "Set WAF limit above this"
        }
      },

      # Average Request Rate
      {
        type   = "metric"
        x      = 4
        y      = 18
        width  = 4
        height = 3
        properties = {
          metrics = [
            [{
              expression = "m1/PERIOD(m1)*60",
              label      = "Avg Rate",
              id         = "e1"
            }],
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_dimension, {
              stat    = "Average",
              id      = "m1",
              visible = false
            }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Avg req/min"
          period = 60
        }
      },

      # Avg explanation
      {
        type   = "text"
        x      = 4
        y      = 20
        width  = 4
        height = 1
        properties = {
          markdown = "Typical steady-state load"
        }
      },

      # Min Request Rate
      {
        type   = "metric"
        x      = 8
        y      = 18
        width  = 4
        height = 3
        properties = {
          metrics = [
            [{
              expression = "m1/PERIOD(m1)*60",
              label      = "Min Rate",
              id         = "e1"
            }],
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_dimension, {
              stat    = "Minimum",
              id      = "m1",
              visible = false
            }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Min req/min"
          period = 60
        }
      },

      # Min explanation
      {
        type   = "text"
        x      = 8
        y      = 20
        width  = 4
        height = 1
        properties = {
          markdown = "Quiet period baseline"
        }
      },

      # Widget 3B (LEFT): Requests Per Minute Graph
      {
        type   = "metric"
        x      = 0
        y      = 21
        width  = 12
        height = 7
        properties = {
          metrics = [
            [{
              expression = "m1/PERIOD(m1)*60",
              label      = "Requests per Minute",
              id         = "e1",
              color      = "#1f77b4"
            }],
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", local.alb_dimension, {
              stat    = "Sum",
              id      = "m1",
              visible = false
            }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "3. Request Rate Over Time"
          period  = 60
          yAxis = {
            left = {
              label     = "Requests/min"
              showUnits = false
            }
          }
        }
      },

      # Widget 4 (RIGHT): ALB Response Times - Single Value Display

      # Average Response Time (top left)
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 6
        height = 3
        properties = {
          metrics = [
            [{
              expression = "m1*1000",
              label      = "Avg Response",
              id         = "e1"
            }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", local.alb_dimension, {
              stat    = "Average",
              id      = "m1",
              visible = false
            }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Avg Response (ms)"
          period = 300
        }
      },

      # Avg explanation
      {
        type   = "text"
        x      = 12
        y      = 21
        width  = 6
        height = 1
        properties = {
          markdown = "Mean time for all requests"
        }
      },

      # p95 Response Time (top right)
      {
        type   = "metric"
        x      = 18
        y      = 18
        width  = 6
        height = 3
        properties = {
          metrics = [
            [{
              expression = "m1*1000",
              label      = "p95 Response",
              id         = "e1"
            }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", local.alb_dimension, {
              stat    = "p95",
              id      = "m1",
              visible = false
            }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "p95 Response (ms)"
          period = 300
        }
      },

      # p95 explanation
      {
        type   = "text"
        x      = 18
        y      = 21
        width  = 6
        height = 1
        properties = {
          markdown = "95% of requests faster than this"
        }
      },

      # p99 Response Time (bottom left)
      {
        type   = "metric"
        x      = 12
        y      = 22
        width  = 6
        height = 3
        properties = {
          metrics = [
            [{
              expression = "m1*1000",
              label      = "p99 Response",
              id         = "e1"
            }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", local.alb_dimension, {
              stat    = "p99",
              id      = "m1",
              visible = false
            }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "p99 Response (ms)"
          period = 300
        }
      },

      # p99 explanation
      {
        type   = "text"
        x      = 12
        y      = 25
        width  = 6
        height = 1
        properties = {
          markdown = "99% of requests faster (slowest 1%)"
        }
      },

      # Max Response Time (bottom right)
      {
        type   = "metric"
        x      = 18
        y      = 22
        width  = 6
        height = 3
        properties = {
          metrics = [
            [{
              expression = "m1*1000",
              label      = "Max Response",
              id         = "e1"
            }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", local.alb_dimension, {
              stat    = "Maximum",
              id      = "m1",
              visible = false
            }]
          ]
          view   = "singleValue"
          region = var.aws_region
          title  = "Max Response (ms)"
          period = 300
        }
      },

      {
        type   = "text"
        x      = 12
        y      = 26
        width  = 12
        height = 3
        properties = {
          markdown = <<-EOT
            **Widget 4 Notes – Response Times:**

            • **Avg (ms):** Average response time across all requests—represents typical user experience.  
            • **p95 (ms):** 95% of requests complete faster than this—good view of upper-tail latency without outliers.  
            • **p99 (ms):** 99% complete faster than this—high-sensitivity to rare slow paths and edge cases.  
            • **Max (ms):** Single slowest request in the window—useful for spotting anomalies and timeouts.

            **Tip:** Percentiles need adequate traffic to differentiate. As rough guidance: 20–50 ms = excellent, 50–200 ms = good, 200–500 ms = acceptable for many APIs (context matters).
          EOT
        }
      },

      # =========================================================================
      # ROW 3 HEADER: Error Rates & Connection Tracking
      # =========================================================================
      {
        type   = "text"
        x      = 0
        y      = 29
        width  = 24
        height = 1
        properties = {
          markdown = "## 🚨 Row 3: Error Rates & Connection Tracking"
        }
      },

      # Widget 5 (LEFT): ALB & Target Error Counts – singleValue, inherits dashboard time range
      {
        type   = "metric"
        x      = 0
        y      = 30
        width  = 12
        height = 3
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Target 4XX (Client Errors)",
              color = "#FF9900"
            }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Target 5XX (Server Errors)",
              color = "#D13212"
            }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "ALB 4XX (LB Rejected)",
              color = "#1f77b4"
            }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "ALB 5XX (LB Failures)",
              color = "#8B0000"
            }]
          ]
          view                 = "singleValue"
          region               = var.aws_region
          title                = "5. Error Totals (Target vs ALB)"
          setPeriodToTimeRange = true
        }
      },

      # Widget 6 (RIGHT): ALB Connection Metrics
      {
        type   = "metric"
        x      = 12
        y      = 30
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Active Connections",
              color = "#1f77b4"
            }],
            ["AWS/ApplicationELB", "NewConnectionCount", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "New Connections",
              color = "#2ca02c"
            }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "6. ALB Connection Metrics"
          period  = 300
          yAxis = {
            left = {
              label     = "Connection Count"
              showUnits = false
            }
          }
        }
      },

      # Widget Notes for Row 3
      {
        type   = "text"
        x      = 0
        y      = 36
        width  = 12
        height = 5
        properties = {
          markdown = <<-EOT
            **Widget 5 Notes – Error Totals (Selected Time Range):**

            • **Target 4XX (Client Errors):** Your **application** returned client errors (e.g., 400 Bad Request, 401 Unauthorized, 404 Not Found, 429 Too Many Requests). Often caused by bad inputs or misuse of the API.

            • **Target 5XX (Server Errors):** Your **application** failed to process requests (e.g., 500 Internal Server Error, 503 Service Unavailable). Investigate app logs, dependencies, and resource pressure.

            • **ALB 4XX (LB Rejected):** The **load balancer** rejected requests before they reached your app (e.g., malformed requests 400, timeouts 408, payload too large 413, SSL/TLS issues 460/463). Indicates client/protocol problems at the edge.

            • **ALB 5XX (LB Failures):** The **load balancer** could not forward or get a response (e.g., 502 Bad Gateway, 503 No healthy targets, 504 Gateway Timeout). Points to infra issues like unhealthy targets, networking, or timeouts.

            These are single totals so you can spot issues at a glance. Use **Widget 8** to see how these codes vary **over time**.
          EOT
        }
      },
      {
        type   = "text"
        x      = 12
        y      = 36
        width  = 12
        height = 3
        properties = {
          markdown = <<-EOT
            **Widget 6 Notes – Connections (ALB):**
            • **Active Connections:** How many TCP connections are currently open with the ALB—reflects concurrent clients/keep-alives (and long-lived connections like WebSockets).  
            • **New Connections:** How many new TCP connections were established during each interval—spikes = bursts of traffic or poor connection reuse.

            This shows **front-door load** on the ALB. Pair with response times and error codes to understand whether spikes correlate with latency or failures.
          EOT
        }
      },

      # =========================================================================
      # ROW 4 HEADER: Backend Health & Response Distribution
      # =========================================================================
      {
        type   = "text"
        x      = 0
        y      = 38
        width  = 24
        height = 1
        properties = {
          markdown = "## 💚 Row 4: Data Volume & Response Distribution"
        }
      },

      # Widget 7: Processed Bytes
      {
        type   = "metric"
        x      = 0
        y      = 39
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "ProcessedBytes", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Total Bytes Processed",
              color = "#1f77b4"
            }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "7. Data Volume (Bytes Processed)"
          period  = 300
          yAxis = {
            left = {
              label     = "Bytes"
              showUnits = false
            }
          }
        }
      },

      # Widget 8 (RIGHT): HTTP Response Code Distribution (over time)
      {
        type   = "metric"
        x      = 12
        y      = 39
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "2XX Success",
              color = "#2ca02c"
            }],
            ["AWS/ApplicationELB", "HTTPCode_Target_3XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "3XX Redirects",
              color = "#1f77b4"
            }],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Target 4XX",
              color = "#ff9900"
            }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", local.alb_dimension, {
              stat  = "Sum",
              label = "Target 5XX",
              color = "#d13212"
            }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "8. Response Code Distribution"
          period  = 300
          yAxis = {
            left = {
              label     = "Request Count"
              showUnits = false
            }
          }
        }
      },

      # Widget Notes for Row 4
      {
        type   = "text"
        x      = 0
        y      = 45
        width  = 12
        height = 4
        properties = {
          markdown = <<-EOT
            **Widget 7 Notes – Data Volume (Bytes Processed):**
            
            Shows total bytes transferred through the ALB (requests + responses). Critical for detecting abuse beyond just request count.
            
            **Watch for:**  
            • **Traffic abuse/scraping:** Massive byte spikes without proportional request increases = someone downloading large datasets repeatedly  
            • **DDoS attacks:** Sudden 10x-100x spike in bytes processed = flood of traffic attempting to overwhelm infrastructure  
            • **Data exfiltration:** Unusual patterns like steady high outbound bytes during off-hours = potential unauthorized data extraction  
            • **API misuse:** High bytes-per-request ratio = users requesting full datasets instead of paginated results
            
            **Rate limiting insight:** If bytes spike but request rate stays normal, consider bandwidth-based limits in addition to request-based limits.
          EOT
        }
      },
      {
        type   = "text"
        x      = 12
        y      = 45
        width  = 12
        height = 4
        properties = {
          markdown = <<-EOT
            **Widget 8 Notes – Response Codes Over Time:**
            • **2XX (Success):** Majority should be here—good baseline of healthy traffic.  
            • **3XX (Redirects):** Normal in authentication/SEO flows; sustained spikes can indicate redirect loops/misconfig.  
            • **Target 4XX (Client Errors):** App rejected the request (e.g., 401/404/429). Signals bad inputs or misuse.  
            • **Target 5XX (Server Errors):** App failed to process (500/503). Indicates app bugs, dependency failures, or resource exhaustion.
          EOT
        }
      },

      # =========================================================================
      # FOOTER: Next Steps & Documentation
      # =========================================================================
      {
        type   = "text"
        x      = 0
        y      = 49
        width  = 24
        height = 2
        properties = {
          markdown = <<-EOT
            ---
            ## 📋 Dashboard Usage Guide

            **Phase 1 (Current):** Monitor for 2–3 days to establish baseline traffic patterns. Record average and peak request rates from Widget 3.

            **Phase 2 (Next):** Enable AWS WAF rate limiting in **COUNT** mode to observe potential blocks without impact.

            **Phase 3 (Final):** Switch WAF to **BLOCK** mode after validating that limits don't affect legitimate users.

            **Key Metrics:**  
            • **Widget 3 Peak req/min** → set initial WAF rate limits (use ~2–3× peak).  
            • **Widget 5 Error Totals** → watch for increases after enabling WAF.  
            • **Widget 1 EB Health** → ensure app stability throughout.
          EOT
        }
      }
    ]
  })

}

# =============================================================================
# OUTPUTS
# =============================================================================

output "cloudwatch_dashboard_url" {
  description = "Direct URL to access the CloudWatch monitoring dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${local.dashboard_name}"
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard for reference"
  value       = aws_cloudwatch_dashboard.eb_monitoring.dashboard_name
}

output "alb_dimension" {
  description = "ALB dimension identifier used for CloudWatch metrics (format: app/name/id)"
  value       = local.alb_dimension
}

output "target_group_dimension" {
  description = "Target Group dimension used for CloudWatch metrics (format: targetgroup/name/id)"
  value       = local.target_group_dimension
}

# =============================================================================
# DASHBOARD LAYOUT SUMMARY
# =============================================================================
# Top numbers: Healthy / Unhealthy targets (y=2..5)
# Row 1 header (y=5)
# Row 1 volume stats: Max Requests per Hour/Day/Week (y=6..9)
# Row 1: EB Environment Health | ALB Request Volume (y=9..15)
# Row 2: Request Rate Stats + Graph | Response Time Numbers (y=18..29)
# Row 3: Error Totals | ALB Connection Metrics (y=30..41)
# Row 4: Data Volume | Response Code Distribution (y=39..49)
# Footer: Usage guide (y=49)
# =============================================================================