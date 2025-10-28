resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "${local.instance_name}-Monitoring-Dashboard"

  dashboard_body = jsonencode({
    widgets = [

      # ================= ROW 0: HEADER (full width) =================
      {
        "type" : "text",
        "x" : 0, "y" : 0, "width" : 24, "height" : 1,
        "properties" : {
          "markdown" : "### Monitoring Dashboard – *${local.instance_name}* (${local.instance_id}) | ${var.instance_type}"
        }
      },

      # ================= ROW 1: UPTIME (left col) =================
      {
        "type" : "text",
        "x" : 0, "y" : 1, "width" : 12, "height" : 1,
        "properties" : {
          "markdown" : "**⏲️ Instance Uptime** - How long EC2 has been running"
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 2, "width" : 12, "height" : 3,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "uptime_seconds",
              "InstanceId", "${local.instance_id}",
              { "id" : "m1", "region" : "${local.aws_region}" }
            ],
            [{ "expression" : "m1/60", "label" : "Uptime (Minutes)", "id" : "m2" }],
            [{ "expression" : "m1/3600", "label" : "Uptime (Hours)", "id" : "m3" }],
            [{ "expression" : "m1/86400", "label" : "Uptime (Days)", "id" : "m4" }]
          ],
          "view" : "singleValue",
          "region" : "${local.aws_region}",
          "period" : 300,
          "stat" : "Average",
          "title" : "EC2 Instance Uptime"
        }
      },

      # ================= ROW 1: STATUS CHECKS (right col) =================
      {
        "type" : "text",
        "x" : 12, "y" : 1, "width" : 12, "height" : 1,
        "properties" : {
          "markdown" : "**🚨 EC2 Status Checks** - Non-zero = instance or system failures"
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 2, "width" : 12, "height" : 3,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", "${local.instance_id}", { "stat" : "Maximum", "label" : "Total Failures" }],
            ["AWS/EC2", "StatusCheckFailed_Instance", "InstanceId", "${local.instance_id}", { "stat" : "Maximum", "label" : "Instance Check" }],
            ["AWS/EC2", "StatusCheckFailed_System", "InstanceId", "${local.instance_id}", { "stat" : "Maximum", "label" : "System Check" }]
          ],
          "title" : "EC2 Status Checks (Instance & System)",
          "region" : "${local.aws_region}",
          "view" : "singleValue",
          "period" : 300,
          "stat" : "Maximum"
        }
      },

      # ================= ROW 2: DISK BLOCK (LEFT) =================
      {
        "type" : "text",
        "x" : 0, "y" : 5, "width" : 9, "height" : 1,
        "properties" : {
          "markdown" : "**💽 Disk Utilization**"
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 6, "width" : 9, "height" : 11,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "disk_used",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype,
              { "label" : "Used Space (GiB)", "color" : "#ff7f0e" }
            ],
            [
              "${local.cwagent_namespace}", "disk_free",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype,
              { "label" : "Free Space (GiB)", "color" : "#1f77b4" }
            ],
            [
              "${local.cwagent_namespace}", "disk_total",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype,
              { "label" : "Total Space (GiB)", "color" : "#2ca02c" }
            ]
          ],
          "title" : "Disk Space Usage (GiB)",
          "region" : local.aws_region,
          "view" : "bar",
          "stat" : "Average",
          "period" : 300
        }
      },

      # Disk Space single values (right of bar)
      {
        "type" : "metric",
        "x" : 9, "y" : 6, "width" : 3, "height" : 4,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "disk_used",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype,
              { "stat" : "Average", "label" : "Used Space (GiB)", "color" : "#ff7f0e" }
            ]
          ],
          "title" : "Used Space (GiB)",
          "region" : local.aws_region,
          "view" : "singleValue",
          "period" : 300
        }
      },

      {
        "type" : "metric",
        "x" : 9, "y" : 10, "width" : 3, "height" : 4,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "disk_free",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype,
              { "stat" : "Average", "label" : "Free Space (GiB)", "color" : "#1f77b4" }
            ]
          ],
          "title" : "Free Space (GiB)",
          "region" : local.aws_region,
          "view" : "singleValue",
          "period" : 300
        }
      },

      {
        "type" : "metric",
        "x" : 9, "y" : 14, "width" : 3, "height" : 4,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "disk_total",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype,
              { "stat" : "Average", "label" : "Total Space (GiB)", "color" : "#2ca02c" }
            ]
          ],
          "title" : "Total Space (GiB)",
          "region" : local.aws_region,
          "view" : "singleValue",
          "period" : 300
        }
      },

      # ================= ROW 2: MEMORY BLOCK (RIGHT) =================
      {
        "type" : "text",
        "x" : 12, "y" : 5, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**🧠 Memory Utilization**"
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 6, "width" : 6, "height" : 8,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "mem_used_percent",
              "InstanceId", "${local.instance_id}",
              { "stat" : "Average", "label" : "Mem Avg", "color" : "#1f77b4" }
            ],
            [
              "${local.cwagent_namespace}", "mem_used_percent",
              "InstanceId", "${local.instance_id}",
              { "stat" : "Maximum", "label" : "Mem Max", "color" : "#d62728" }
            ]
          ],
          "title" : "Memory % (Avg/Max) - >80% = memory pressure",
          "region" : local.aws_region,
          "view" : "gauge",
          "period" : 300,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      # Memory Over Time (underneath memory gauge)
      {
        "type" : "text",
        "x" : 12, "y" : 14, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**🧠 Memory Over Time**"
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 15, "width" : 6, "height" : 5,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "mem_used_percent",
              "InstanceId", "${local.instance_id}"
            ]
          ],
          "title" : "Memory % Over Time - Rising trend = may need more RAM",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      # Disk Space Over Time (underneath memory over time)
      {
        "type" : "text",
        "x" : 12, "y" : 20, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**💾 Disk Space Over Time**"
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 21, "width" : 6, "height" : 5,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "disk_used_percent",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype
            ]
          ],
          "title" : "Disk Used % Over Time - Rising = running out of space",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      # Swap Over Time (underneath disk space over time)
      {
        "type" : "text",
        "x" : 12, "y" : 26, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**📉 Swap Over Time**"
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 27, "width" : 6, "height" : 5,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "swap_used_percent",
              "InstanceId", "${local.instance_id}"
            ]
          ],
          "title" : "Swap % Over Time - >0% = low memory, expect slowness",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      # ================= ROW 2: CPU BLOCK (FAR RIGHT) =================
      {
        "type" : "text",
        "x" : 18, "y" : 5, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**💻 CPU Utilization**"
        }
      },
      {
        "type" : "metric",
        "x" : 18, "y" : 6, "width" : 6, "height" : 8,
        "properties" : {
          "metrics" : [
            [
              "AWS/EC2", "CPUUtilization",
              "InstanceId", "${local.instance_id}",
              { "stat" : "Average", "label" : "CPU Avg", "color" : "#1f77b4" }
            ],
            [
              "AWS/EC2", "CPUUtilization",
              "InstanceId", "${local.instance_id}",
              { "stat" : "Maximum", "label" : "CPU Max", "color" : "#d62728" }
            ]
          ],
          "title" : "CPU % (Avg/Max) - >80% = bottleneck",
          "region" : local.aws_region,
          "view" : "gauge",
          "period" : 300,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      # CPU Over Time (underneath CPU gauge)
      {
        "type" : "text",
        "x" : 18, "y" : 14, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**⏱️ CPU Over Time**"
        }
      },
      {
        "type" : "metric",
        "x" : 18, "y" : 15, "width" : 6, "height" : 5,
        "properties" : {
          "metrics" : [
            [
              "AWS/EC2", "CPUUtilization",
              "InstanceId", "${local.instance_id}",
              { "stat" : "Average", "label" : "CPU Avg" }
            ],
            [
              "AWS/EC2", "CPUUtilization",
              "InstanceId", "${local.instance_id}",
              { "stat" : "p99", "label" : "CPU p99", "color" : "#ff7f0e" }
            ]
          ],
          "title" : "CPU % Over Time (Avg & p99)",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300
        }
      },

      # CPU Credit Usage (underneath CPU over time)
      {
        "type" : "text",
        "x" : 18, "y" : 20, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**💳 CPU Credit Usage**"
        }
      },
      {
        "type" : "metric",
        "x" : 18, "y" : 21, "width" : 6, "height" : 5,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUCreditUsage", "InstanceId", "${local.instance_id}"]
          ],
          "title" : "CPU Credit Usage - Rate of credit spending",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300
        }
      },

      # CPU Credit Balance WITH COLORED ZONES (underneath credit usage)
      {
        "type" : "text",
        "x" : 18, "y" : 26, "width" : 6, "height" : 1,
        "properties" : {
          "markdown" : "**⚡ CPU Credit Balance**"
        }
      },
      {
        "type" : "metric",
        "x" : 18, "y" : 27, "width" : 6, "height" : 5,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUCreditBalance", "InstanceId", "${local.instance_id}", { "color" : "#2ca02c" }]
          ],
          "title" : "CPU Credit Balance (T-instances only)",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300,
          "annotations" : {
            "horizontal" : [
              {
                "label" : "🔴 CRITICAL: CPU Throttling",
                "value" : 0,
                "fill" : "above",
                "color" : "#d62728"
              },
              {
                "label" : "🟠 WARNING: Low Credits",
                "value" : 50,
                "fill" : "above",
                "color" : "#ff7f0e"
              },
              {
                "label" : "🟢 HEALTHY: Good Reserve",
                "value" : 100,
                "fill" : "above",
                "color" : "#2ca02c"
              }
            ]
          },
          "yAxis" : {
            "left" : {
              "min" : 0
            }
          }
        }
      },

      # ================= ROW 3: NETWORK BLOCK (LEFT) =================
      {
        "type" : "text",
        "x" : 0, "y" : 17, "width" : 12, "height" : 2,
        "properties" : {
          "markdown" : "**📡 Network Throughput**"
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 18, "width" : 12, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkIn", "InstanceId", "${local.instance_id}", { "label" : "Network In" }],
            ["AWS/EC2", "NetworkOut", "InstanceId", "${local.instance_id}", { "label" : "Network Out" }]
          ],
          "title" : "Network In/Out (Bytes) - Spikes = high traffic",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300
        }
      },

      # Network Packets (underneath network throughput)
      {
        "type" : "text",
        "x" : 0, "y" : 24, "width" : 12, "height" : 1,
        "properties" : {
          "markdown" : "**📦 Network Packets**"
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 25, "width" : 12, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkPacketsIn", "InstanceId", "${local.instance_id}", { "label" : "Packets In" }],
            ["AWS/EC2", "NetworkPacketsOut", "InstanceId", "${local.instance_id}", { "label" : "Packets Out" }]
          ],
          "title" : "Network Packets In/Out - Count of packets sent/received",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "stat" : "Sum",
          "period" : 300
        }
      },

      # ================= ROW 4: DISK LATENCY (BOTTOM FULL WIDTH) =================
      # ================= ROW 4: DISK LATENCY & DISK SPACE OVER TIME (BOTTOM) =================
      {
        "type" : "text",
        "x" : 0, "y" : 31, "width" : 12, "height" : 1,
        "properties" : {
          "markdown" : "**💽 Disk Latency** - High read/write time = I/O bottleneck"
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 32, "width" : 12, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EBS", "VolumeTotalReadTime", "VolumeId", "${local.root_volume_id}", { "label" : "Read Time" }],
            ["AWS/EBS", "VolumeTotalWriteTime", "VolumeId", "${local.root_volume_id}", { "label" : "Write Time" }]
          ],
          "title" : "Disk Read/Write Time (Seconds) - Spikes = slow disk I/O",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300
        }
      },

      # Disk Space Over Time (right side of disk latency)
      {
        "type" : "text",
        "x" : 12, "y" : 31, "width" : 12, "height" : 1,
        "properties" : {
          "markdown" : "**💾 Disk Space Over Time**"
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 32, "width" : 12, "height" : 6,
        "properties" : {
          "metrics" : [
            [
              "${local.cwagent_namespace}", "disk_used_percent",
              "InstanceId", "${local.instance_id}",
              "path", local.disk_path,
              "device", local.disk_device,
              "fstype", local.disk_fstype,
              { "label" : "Disk Used %", "color" : "#ff7f0e" }
            ]
          ],
          "title" : "Disk Used % Over Time - Rising = running out of space",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "period" : 300,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } },
          "annotations" : {
            "horizontal" : [
              {
                "label" : "🔴 CRITICAL: Very Low Space",
                "value" : 90,
                "fill" : "above",
                "color" : "#d62728"
              },
              {
                "label" : "🟠 WARNING: Low Space",
                "value" : 80,
                "fill" : "above",
                "color" : "#ff7f0e"
              }
            ]
          }
        }
      }

    ]
  })
}