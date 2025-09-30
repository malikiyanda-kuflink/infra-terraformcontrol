locals {
  disk_size_gb = aws_instance.kuflink_ec2.root_block_device[0].volume_size

}


resource "aws_cloudwatch_dashboard" "kuflink_dashboard" {
  dashboard_name = "Kuflink-Test-Wordpress-EC2-Monitoring-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # CPU Utilization
      {
        "type" : "metric",
        "x" : 18, "y" : 0, "width" : 6, "height" : 8,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.kuflink_ec2.id}", { "stat" : "Average", "label" : "CPU Avg" }],
            ["AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.kuflink_ec2.id}", { "stat" : "Maximum", "label" : "CPU Max" }]
          ],
          "title" : "CPU Utilization (Avg & Max)",
          "region" : "eu-west-2",
          "view" : "gauge",
          "period" : 5, # Fetch data every 5 seconds
          "liveData" : true,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },
      # Memory Utilization ()
      {
        "type" : "metric",
        "x" : 12, "y" : 2, "width" : 6, "height" : 8,
        "properties" : {
          "metrics" : [["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "mem_used_percent", "InstanceId", "${aws_instance.kuflink_ec2.id}"]],
          "title" : "Memory Utilization (Gauge)",
          "region" : "eu-west-2",
          "view" : "gauge",
          "liveData" : true,
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },
      # Disk Space Usage bar
      {
        "type" : "metric",
        "x" : 0, "y" : 12, "width" : 8, "height" : 9,
        "properties" : {
          "metrics" : [
            ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_used", "path", "/", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p1", "fstype", "ext4", { "id" : "m1", "label" : "Used Space (GB)" }],
            [{ "expression" : "(m2 - m1) * 0.931", "label" : "Root Free Space (GiB)", "id" : "m9" }],
            ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_total", "path", "/", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p1", "fstype", "ext4", { "id" : "m2", "label" : "Total Space (GB)" }]
          ],
          "title" : "Disk Space Usage (GiB)",
          "region" : "eu-west-2",
          "view" : "bar",
          "stat" : "Average",
          "period" : 300
        }
      },
      # Disk Space Usage Number
      {
        "type" : "metric",
        "x" : 0, "y" : 12, "width" : 12, "height" : 3,
        "properties" : {
          "metrics" : [
            ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_used", "path", "/", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p1", "fstype", "ext4", { "id" : "m1", "label" : "Used Space (GB)" }],
            [{ "expression" : "(m2 - m1) * 0.931", "label" : "Root Free Space (GiB)", "id" : "m9" }],
            ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_total", "path", "/", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p1", "fstype", "ext4", { "id" : "m2", "label" : "Total Space (GB)" }]
            # ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_used", "path", "/boot", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p16", "fstype", "ext4", { "id": "m4", "label": "Boot Used (GB)" }],
            # ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_total", "path", "/boot", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p16", "fstype", "ext4", { "id": "m5", "label": "Boot Total (GB)" }],
            # ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_used", "path", "/boot/efi", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p15", "fstype", "vfat", { "id": "m6", "label": "Boot EFI Used (GB)" }],
            # ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_total", "path", "/boot/efi", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p15", "fstype", "vfat", { "id": "m7", "label": "Boot EFI Total (GB)" }],

          ],
          "title" : "Disk Space Usage",
          "region" : "eu-west-2",
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
      # Current Disk Operations per Second (Single Value)
      {
        "type" : "metric",
        "x" : 8, "y" : 8, "width" : 4, "height" : 3,
        "properties" : {
          "metrics" : [["AWS/EC2", "EBSReadOps", "InstanceId", "${aws_instance.kuflink_ec2.id}", { "stat" : "Sum" }]],
          "title" : "Current Disk Operations per Second",
          "region" : "eu-west-2",
          "view" : "singleValue"
        }
      },

      # Current Network Throughput (Single Value)
      {
        "type" : "metric",
        "x" : 8, "y" : 8, "width" : 4, "height" : 3,
        "properties" : {
          "metrics" : [["AWS/EC2", "NetworkIn", "InstanceId", "${aws_instance.kuflink_ec2.id}", { "stat" : "Sum" }]],
          "title" : "Current Network Throughput",
          "region" : "eu-west-2",
          "view" : "singleValue"
        }
      },

      # Swap Usage (Single Value instead of Gauge)
      {
        "type" : "metric",
        "x" : 8, "y" : 8, "width" : 4, "height" : 3
        "properties" : {
          "metrics" : [["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "swap_used_percent", "InstanceId", "${aws_instance.kuflink_ec2.id}"]],
          "title" : "Swap Usage (%)",
          "region" : "eu-west-2",
          "view" : "singleValue"
        }
      },
      # CPU Utilization Over Time (Line Chart)
      {
        "type" : "metric",
        "x" : 18, "y" : 0, "width" : 6, "height" : 6,

        "properties" : {
          "metrics" : [["AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.kuflink_ec2.id}"]],
          "title" : "CPU Utilization Over Time",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      },

      # Network In/Out (Line Chart)
      {
        "type" : "metric",

        "x" : 0, "y" : 14, "width" : 12, "height" : 4,

        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkIn", "InstanceId", "${aws_instance.kuflink_ec2.id}"],
            ["AWS/EC2", "NetworkOut", "InstanceId", "${aws_instance.kuflink_ec2.id}"]
          ],
          "title" : "Network In/Out",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      },

      {
        "type" : "metric",
        "x" : 0, "y" : 14, "width" : 12, "height" : 4,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "NetworkPacketsIn", "InstanceId", "${aws_instance.kuflink_ec2.id}", { "label" : "Network Packets In" }],
            ["AWS/EC2", "NetworkPacketsOut", "InstanceId", "${aws_instance.kuflink_ec2.id}", { "label" : "Network Packets Out" }]
          ],
          "title" : "Network Packets In/Out",
          "region" : "eu-west-2",
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


      # Swap Usage Over Time (Line Chart)
      {
        "type" : "metric",
        "x" : 12, "y" : 4, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "swap_used_percent", "InstanceId", "${aws_instance.kuflink_ec2.id}"]],
          "title" : "Swap Usage Over Time",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      },

      # Memory Utilization Over Time (Line Chart)
      {
        "type" : "metric",
        "x" : 12, "y" : 4, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "mem_used_percent", "InstanceId", "${aws_instance.kuflink_ec2.id}"]],
          "title" : "Memory Utilization Over Time",
          "region" : "eu-west-2",
          "view" : "timeSeries",
          "yAxis" : { "left" : { "min" : 0, "max" : 100 } }
        }
      },

      # Disk Read/Write Operations (Line Chart)
      {
        "type" : "metric",
        "x" : 6, "y" : 14, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "EBSReadOps", "InstanceId", "${aws_instance.kuflink_ec2.id}"],
            ["AWS/EC2", "EBSWriteOps", "InstanceId", "${aws_instance.kuflink_ec2.id}"]
          ],
          "title" : "Disk Read/Write Operations",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      },

      # Disk Space Usage Over Time (Line Chart)
      {
        "type" : "metric",
        "x" : 12, "y" : 14, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}", "disk_used_percent", "path", "/", "InstanceId", "${aws_instance.kuflink_ec2.id}", "device", "nvme0n1p1", "fstype", "ext4"]
          ],
          "title" : "Disk Space Usage Over Time",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      },

      # EC2 Status Checks (Instance & System)
      {
        "type" : "metric",
        "x" : 12, "y" : 0, "width" : 12, "height" : 3,
        "properties" : {
          "metrics" : [
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", "${aws_instance.kuflink_ec2.id}"],
            ["AWS/EC2", "StatusCheckFailed_Instance", "InstanceId", "${aws_instance.kuflink_ec2.id}"],
            ["AWS/EC2", "StatusCheckFailed_System", "InstanceId", "${aws_instance.kuflink_ec2.id}"]
          ],
          "title" : "EC2 Status Checks (Instance & System)",
          "region" : "eu-west-2",
          "view" : "singleValue"
        }
      },

      # EC2 Instance Uptime "x": 0, "y": 8, "width": 12, "height": 6,
      {
        "type" : "metric",
        "x" : 0, "y" : 0, "width" : 12, "height" : 3,

        "properties" : {
          "metrics" : [
            [
              "CWAgent-${aws_instance.kuflink_ec2.tags["Name"]}",
              "collectd_uptime_value",
              "InstanceId",
              "${aws_instance.kuflink_ec2.id}",
              "type",
              "uptime",
              { "id" : "m1" }
            ],
            [
              { "expression" : "m1/60", "label" : "Uptime (Minutes)", "id" : "m2" }
            ],
            [
              { "expression" : "m1/3600", "label" : "Uptime (Hours)", "id" : "m3" }
            ],
            [
              { "expression" : "m1/86400", "label" : "Uptime (Days)", "id" : "m4" }
            ]
          ],
          "title" : "EC2 Instance Uptime",
          "region" : "eu-west-2",
          "view" : "singleValue"
        }
      },
      # Disk Latency (Read/Write)
      {
        "type" : "metric",
        "x" : 0, "y" : 14, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/EBS", "VolumeTotalReadTime", "VolumeId", "${data.aws_ebs_volume.kuflink_root_volume.id}"],
            ["AWS/EBS", "VolumeTotalWriteTime", "VolumeId", "${data.aws_ebs_volume.kuflink_root_volume.id}"]
          ],
          "title" : "Disk Latency (Read/Write)",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      },


      # CPU Credit Balance (For burstable instances)
      {
        "type" : "metric",
        "x" : 18, "y" : 12, "width" : 6, "height" : 6,


        "properties" : {
          "metrics" : [["AWS/EC2", "CPUCreditBalance", "InstanceId", "${aws_instance.kuflink_ec2.id}"]],
          "title" : "CPU Credit Balance",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      },
      # CPU Steal Time
      {
        "type" : "metric",
        "x" : 18, "y" : 12, "width" : 6, "height" : 6,
        "properties" : {
          "metrics" : [["AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.kuflink_ec2.id}", { "stat" : "p99" }]],
          "title" : "CPU Steal Time (p99)",
          "region" : "eu-west-2",
          "view" : "timeSeries"
        }
      }
    ]
  })
}

data "aws_ebs_volume" "kuflink_root_volume" {
  filter {
    name   = "attachment.instance-id"
    values = [aws_instance.kuflink_ec2.id]
  }
}
