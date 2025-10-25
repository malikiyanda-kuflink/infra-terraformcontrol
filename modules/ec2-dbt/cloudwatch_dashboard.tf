resource "aws_cloudwatch_dashboard" "kuflink_dashboard" {
  dashboard_name = "${local.instance_name}-Monitoring-Dashboard"

  dashboard_body = jsonencode({
    widgets = [

      {
        "type" : "text",
        "x" : 0, "y" : 0, "width" : 24, "height" : 1,
        "properties" : {
          "markdown" : "### Monitoring Dashboard – *${local.instance_name}* (${local.instance_id})"
        }
      },

      {
        "type" : "text",
        "x" : 18, "y" : 0, "width" : 6, "height" : 2,
        "properties" : {
          "markdown" : "**🧠 CPU Utilization**\nShows average and max CPU usage. >80% = bottlenecks or scaling need."
        }
      },
      {
        "type" : "metric",
        "x" : 18, "y" : 0, "width" : 6, "height" : 8,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${local.instance_id}", { "stat" : "Average", "label" : "CPU Avg" }],
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${local.instance_id}", { "stat" : "Maximum", "label" : "CPU Max" }]
          ],
          "title" : "CPU Utilization (Avg & Max)",
          "region" : local.aws_region,
          "view" : "gauge",
          "period" : 5,
          "liveData" : true,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      {
        "type" : "text",
        "x" : 12, "y" : 2, "width" : 6, "height" : 2,
        "properties" : {
          "markdown" : "**🧠 Memory Utilization**\nRAM usage. Persistent >80% may mean memory leaks or need to scale."
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 2, "width" : 6, "height" : 8,
        "properties" : {
          "metrics" : [
            ["${local.cwagent_namespace}", "mem_used_percent", "InstanceId", "${local.instance_id}", { "stat" : "Average", "label" : "Mem Avg" }],
            ["${local.cwagent_namespace}", "mem_used_percent", "InstanceId", "${local.instance_id}", { "stat" : "Maximum", "label" : "Mem Max" }]
          ],
          "title" : "Memory Utilization (Gauge)",
          "region" : local.aws_region,
          "view" : "gauge",
          "liveData" : true,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },
      {
        "type" : "text",
        "x" : 0, "y" : 11, "width" : 8, "height" : 2,
        "properties" : {
          "markdown" : "**💾 Disk Space Usage**\nUsed/free/total disk. Low free space (<10%) = cleanup or disk expansion."
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 12, "width" : 8, "height" : 9,
        "properties" : {
          "metrics" : [
            ["${local.cwagent_namespace}", "disk_used", "InstanceId", "${local.instance_id}", "path", local.disk_path, "device", local.disk_device, "fstype", local.disk_fstype, { "id" : "m1", "label" : "Used Space (GiB)" }],
            ["${local.cwagent_namespace}", "disk_free", "InstanceId", "${local.instance_id}", "path", local.disk_path, "device", local.disk_device, "fstype", local.disk_fstype, { "id" : "m2", "label" : "Free Space (GiB)" }],
            ["${local.cwagent_namespace}", "disk_total", "InstanceId", "${local.instance_id}", "path", local.disk_path, "device", local.disk_device, "fstype", local.disk_fstype, { "id" : "m3", "label" : "Total Space (GiB)" }]
          ],
          "title" : "Disk Space Usage (GiB)",
          "region" : local.aws_region,
          "view" : "bar",
          "stat" : "Average",
          "period" : 300
        }
      },

      {
        "type" : "metric",
        "x" : 0, "y" : 12, "width" : 12, "height" : 3,
        "properties" : {
          "metrics" : [
            ["${local.cwagent_namespace}", "disk_used", "InstanceId", "${local.instance_id}", "path", local.disk_path, "device", local.disk_device, "fstype", local.disk_fstype, { "id" : "m1", "label" : "Used Space (GiB)" }],
            ["${local.cwagent_namespace}", "disk_free", "InstanceId", "${local.instance_id}", "path", local.disk_path, "device", local.disk_device, "fstype", local.disk_fstype, { "id" : "m2", "label" : "Free Space (GiB)" }],
            ["${local.cwagent_namespace}", "disk_total", "InstanceId", "${local.instance_id}", "path", local.disk_path, "device", local.disk_device, "fstype", local.disk_fstype, { "id" : "m3", "label" : "Total Space (GiB)" }]
          ],
          "title" : "Disk Space Usage",
          "region" : local.aws_region,
          "view" : "singleValue",
          "stat" : "Average",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 120
            }
          }
        }
      },

      {
        "type" : "text",
        "x" : 8, "y" : 7, "width" : 4, "height" : 2,
        "properties" : {
          "markdown" : "**🔁 Disk IOPS**\nRead/write ops/sec. Spikes = disk activity or contention."
        }
      },
      {
        "type" : "metric",
        "x" : 8, "y" : 8, "width" : 4, "height" : 3,
        "properties" : {
          "metrics" : [["AWS/EC2", "EBSReadOps", "InstanceId", "${local.instance_id}", { "stat" : "Sum" }]],
          "title" : "Current Disk Operations per Second",
          "region" : local.aws_region,
          "view" : "singleValue"
        }
      },

      {
        "type" : "text",
        "x" : 8, "y" : 7, "width" : 4, "height" : 2,
        "properties" : {
          "markdown" : "**📡 Network Throughput**\nVolume of data in/out. Spikes = load, attacks, or backup traffic."
        }
      },
      {
        "type" : "metric",
        "x" : 8, "y" : 8, "width" : 4, "height" : 3,
        "properties" : {
          "metrics" : [["AWS/EC2", "NetworkIn", "InstanceId", "${local.instance_id}", { "stat" : "Sum" }]],
          "title" : "Current Network Throughput",
          "region" : local.aws_region,
          "view" : "singleValue"
        }
      },

      {
        "type" : "text",
        "x" : 8, "y" : 7, "width" : 4, "height" : 2,
        "properties" : {
          "markdown" : "**📉 Swap Usage**\nSwap used when RAM is full. High values = memory pressure or leak."
        }
      },
      {
        "type" : "metric",
        "x" : 8, "y" : 8, "width" : 4, "height" : 3,
        "properties" : {
          "metrics" : [["${local.cwagent_namespace}", "swap_used_percent"]],
          "title" : "Swap Usage (%)",
          "region" : local.aws_region,
          "view" : "singleValue"
        }
      },
      {
        "type" : "text",
        "x" : 0, "y" : 13, "width" : 12, "height" : 2,
        "properties" : {
          "markdown" : "**📡 Network Throughput**\nVolume of data in/out. Spikes = load, attacks, or backup traffic."
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 14, "width" : 12, "height" : 4,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkIn", "InstanceId", "${local.instance_id}"],
            ["AWS/EC2", "NetworkOut", "InstanceId", "${local.instance_id}"]
          ],
          "title" : "Network In/Out",
          "region" : local.aws_region,
          "view" : "timeSeries"
        }
      },

      {
        "type" : "text",
        "x" : 0, "y" : 13, "width" : 12, "height" : 2,
        "properties" : {
          "markdown" : "**📦 Network Packets**\nTracks number of packets. Spikes = bursts or DDoS risk."
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 14, "width" : 12, "height" : 4,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkPacketsIn", "InstanceId", "${local.instance_id}", { "label" : "Network Packets In" }],
            ["AWS/EC2", "NetworkPacketsOut", "InstanceId", "${local.instance_id}", { "label" : "Network Packets Out" }]
          ],
          "title" : "Network Packets In/Out",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "stat" : "Sum",
          "period" : 300,
          "yAxis" : {
            "left" : {
              "label" : "Packets",
              "showUnits" : false
            }
          }
        }
      },

      {
        "type" : "text",
        "x" : 12, "y" : 3, "width" : 6, "height" : 2,
        "properties" : {
          "markdown" : "**📉 Swap Usage**\nSwap used over time. Sustained use = RAM exhaustion or misconfigured workload."
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 4, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["${local.cwagent_namespace}", "swap_used_percent", "InstanceId", "${local.instance_id}"]
          ],
          "title" : "Swap Usage Over Time",
          "region" : local.aws_region,
          "view" : "timeSeries"
        }
      },

      {
        "type" : "text",
        "x" : 12, "y" : 3, "width" : 6, "height" : 2,
        "properties" : {
          "markdown" : "**🧠 Memory Utilization**\nUsed memory over time. Spikes may indicate inefficient memory use or leaks."
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 4, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["${local.cwagent_namespace}", "mem_used_percent", "InstanceId", "${local.instance_id}"]
          ],
          "title" : "Memory Utilization Over Time",
          "region" : local.aws_region,
          "view" : "timeSeries",
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      {
        "type" : "text",
        "x" : 12, "y" : 0, "width" : 12, "height" : 2,
        "properties" : {
          "markdown" : "**🚨 EC2 Status Checks**\nNon-zero = instance or system failures. Needs immediate attention."
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 0, "width" : 12, "height" : 3,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", "${local.instance_id}"],
            ["AWS/EC2", "StatusCheckFailed_Instance", "InstanceId", "${local.instance_id}"],
            ["AWS/EC2", "StatusCheckFailed_System", "InstanceId", "${local.instance_id}"]
          ],
          "title" : "EC2 Status Checks (Instance & System)",
          "region" : local.aws_region,
          "view" : "singleValue"
        }
      },

      {
        "type" : "text",
        "x" : 0, "y" : 0, "width" : 12, "height" : 2,
        "properties" : {
          "markdown" : "**⏲️ Instance Uptime**\nHow long EC2 has been running. Useful for patching/stability audits."
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 0, "width" : 12, "height" : 3,
        "properties" : {
          "metrics" : [
            ["${local.cwagent_namespace}", "collectd_uptime_value", "InstanceId", "${local.instance_id}", "type", "uptime", { "id": "m1", "region": "${local.aws_region}" }],
            [{ "expression": "m1/60", "label": "Uptime (Minutes)", "id": "m2" }],
            [{ "expression": "m1/3600", "label": "Uptime (Hours)", "id": "m3" }],
            [{ "expression": "m1/86400", "label": "Uptime (Days)", "id": "m4" }]
          ],
          "view": "singleValue",
          "region": "${local.aws_region}",
          "period": 60,
          "stat": "Average",
          "title": "EC2 Instance Uptime",
          "liveData": false,
          "stacked": false,
          "yAxis": {
            "left": { "min": 0 },
            "right": { "showUnits": true }
          }
        }
      },
      {
        "type" : "text",
        "x" : 0, "y" : 13, "width" : 6, "height" : 2,
        "properties" : {
          "markdown" : "**💽 Disk Latency**\nHigh read/write time = I/O bottleneck. Investigate if over ~10ms."
        }
      },
      {
        "type" : "metric",
        "x" : 0, "y" : 14, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EBS", "VolumeTotalReadTime", "VolumeId", "${local.root_volume_id}"],
            ["AWS/EBS", "VolumeTotalWriteTime", "VolumeId", "${local.root_volume_id}"]
          ],
          "title" : "Disk Latency (Read/Write)",
          "region" : local.aws_region,
          "view" : "timeSeries"
        }
      },

      {
        "type" : "text",
        "x" : 18, "y" : 11, "width" : 6, "height" : 2,
        "properties" : {
          "markdown" : "**⚡ CPU Credit Balance**\nBurstable T2/T3 instances need credit reserve. Low = throttling risk."
        }
      },
      {
        "type" : "metric",
        "x" : 18, "y" : 12, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUCreditBalance", "InstanceId", "${local.instance_id}"]
          ],
          "title" : "CPU Credit Balance",
          "region" : local.aws_region,
          "view" : "timeSeries"
        }
      },

      {
        "type" : "text",
        "x" : 18, "y" : 11, "width" : 6, "height" : 2,
        "properties" : {
          "markdown" : "**⏱️ CPU Steal Time**\np99 CPU time taken by other VMs on host. High = noisy neighbor."
        }
      },
      {
        "type" : "metric",
        "x" : 18, "y" : 12, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${local.instance_id}", { "stat" : "p99" }]
          ],
          "title" : "CPU Steal Time (p99)",
          "region" : local.aws_region,
          "view" : "timeSeries"
        }
      }

    ]
  })
}
