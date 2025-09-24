resource "aws_cloudwatch_dashboard" "rds_mysql" {
  dashboard_name = "${var.name_prefix_upper}-RDS-MySQL"
dashboard_body = jsonencode({ 
  widgets = [
    # ===== HEADER =====
    {
      "type": "text", "x": 0, "y": 0, "width": 24, "height": 2,
      "properties": {
        "markdown": "# 🗄️ RDS Database Monitoring Dashboard\n## 📊 Database: ${local.identifier}"
      }
    },

    # ===== ALERT STATUS LEGEND =====
    {
      "type": "text", "x": 0, "y": 2, "width": 24, "height": 1,
      "properties": {
        "markdown": "🟢 **FINE** | 🟡 **WARNING** | 🔴 **CRITICAL** | 📈 **Real-time Monitoring Active**"
      }
    },

    # ===== CONNECTIONS & STORAGE ROW =====
    {
      "type": "text", "x": 0, "y": 3, "width": 12, "height": 1,
      "properties": {
        "markdown": "### 🔗 Active Connections\n🟢 1-59 | 🟡 60-79 | 🔴 ≥80 or <1"
      }
    },

    {
      "type": "text", "x": 12, "y": 3, "width": 12, "height": 1,
      "properties": {
        "markdown": "### 💿 Free Storage Space\n🟢 >20GB | 🟡 10-20GB | 🔴 <10GB"
      }
    },

    # Connections Widget
    {
      "type": "metric", "x": 0, "y": 4, "width": 12, "height": 3,
      "properties": {
        "title": "🔗 Active Database Connections",
        "region": "eu-west-2", 
        "view": "singleValue", 
        "stat": "Average",
        "period": 300,
        "sparkline": true, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", local.identifier]],
        "yAxis": { "left": { "min": 0 } }
      }
    },

    # Storage Widget
    {
      "type": "metric", "x": 12, "y": 4, "width": 12, "height": 3,
      "properties": {
        "title": "💿 Free Storage Space (GB)",
        "region": "eu-west-2", 
        "view": "singleValue", 
        "stat": "Average",
        "period": 300,
        "sparkline": true, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "metrics": [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", local.identifier]],
        "yAxis": { "left": { "min": 0 } }
      }
    },

    # ===== PERFORMANCE TRENDS SECTION =====
    {
      "type": "text", "x": 0, "y": 7, "width": 24, "height": 1,
      "properties": {
        "markdown": "## 📈 Performance Trends & Analysis"
      }
    },

    # CPU Performance Chart - Using number widget for instant visibility
    {
      "type": "metric", "x": 0, "y": 8, "width": 6, "height": 3,
      "properties": {
        "title": "🧠 CPU Average (%) | 🟢 <60% | 🟡 60-79% | 🔴 ≥80%",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", local.identifier]
        ]
      }
    },

    # CPU Peak Chart
    {
      "type": "metric", "x": 6, "y": 8, "width": 6, "height": 3,
      "properties": {
        "title": "🔺 CPU Peak (%)",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Maximum", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", local.identifier]
        ]
      }
    },

    # CPU Credits - Single value with sparkline
    {
      "type": "metric", "x": 12, "y": 8, "width": 6, "height": 3,
      "properties": {
        "title": "⚡ CPU Credits | 🟢 >100 | 🟡 50-100 | 🔴 <50",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [
          ["AWS/RDS", "CPUCreditBalance", "DBInstanceIdentifier", local.identifier]
        ]
      }
    },

    # CPU Credit Usage
    {
      "type": "metric", "x": 18, "y": 8, "width": 6, "height": 3,
      "properties": {
        "title": "🔥 Credit Usage",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [
          ["AWS/RDS", "CPUCreditUsage", "DBInstanceIdentifier", local.identifier]
        ]
      }
    },

    # CPU Trend Chart - Line chart with better scaling
    {
      "type": "metric", "x": 0, "y": 11, "width": 12, "height": 8,
      "properties": {
        "title": "🧠 CPU Utilization Pattern",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0, "max": 100 } },
        "metrics": [
          ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", local.identifier, { "stat": "Average" }]
        ],
        "annotations": {
          "horizontal": [
            { "label": "🔴 CRITICAL", "value": 80, "color": "#d62728" },
            { "label": "🟡 WARNING", "value": 60, "color": "#ff7f0e" }
          ]
        }
      }
    },

    # CPU Credits Trend
    {
      "type": "metric", "x": 12, "y": 11, "width": 12, "height": 8,
      "properties": {
        "title": "⚡ CPU Credit Balance Trend",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "CPUCreditBalance", "DBInstanceIdentifier", local.identifier]
        ],
        "annotations": {
          "horizontal": [
            { "label": "🔴 LOW", "value": 50, "color": "#d62728" },
            { "label": "🟡 WARNING", "value": 100, "color": "#ff7f0e" }
          ]
        }
      }
    },

    # Memory Available
    {
      "type": "metric", "x": 0, "y": 15, "width": 8, "height": 3,
      "properties": {
        "title": "💾 Available Memory (GB) | 🟢 >1GB | 🟡 200MB-1GB | 🔴 <200MB",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", local.identifier]]
      }
    },

    #  DBLoad 
    {
    "type": "metric", "x": 8, "y": 15, "width": 8, "height": 3,
    "properties": {
        "title": "💥 EBS Burst Balance (%)",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "BurstBalance", "DBInstanceIdentifier", local.identifier]]
    }
    },

    # Swap Usage (separate scale)
    {
      "type": "metric", "x": 16, "y": 15, "width": 8, "height": 3,
      "properties": {
        "title": "🔄 Swap Usage (MB)",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "SwapUsage", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # Memory Trend - Only Free Memory with proper scaling
    {
      "type": "metric", "x": 0, "y": 18, "width": 12, "height": 8,
      "properties": {
        "title": "💾 Available Memory Trend (GB)",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", local.identifier]
        ],
        "annotations": {
          "horizontal": [
            { "label": "🔴 CRITICAL (<200MB)", "value": 200000000, "color": "#d62728" },
            { "label": "🟡 WARNING (<1GB)", "value": 1000000000, "color": "#ff7f0e" }
          ]
        }
      }
    },

    # Swap Usage Trend - Separate chart with appropriate scale
    {
      "type": "metric", "x": 12, "y": 18, "width": 12, "height": 8,
      "properties": {
        "title": "🔄 Swap Usage Trend (MB)",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "SwapUsage", "DBInstanceIdentifier", local.identifier]
        ],
        "annotations": {
          "horizontal": [
            { "label": "🔴 HIGH SWAP (>500MB)", "value": 500000000, "color": "#d62728" },
            { "label": "🟡 WARNING (>100MB)", "value": 100000000, "color": "#ff7f0e" }
          ]
        }
      }
    },

    # ===== CONNECTION & STORAGE ANALYSIS =====
    {
      "type": "text", "x": 0, "y": 22, "width": 24, "height": 1,
      "properties": {
        "markdown": "## 🔗 Connection Activity & 💿 Storage Management"
      }
    },

    # Connection Current
    {
      "type": "metric", "x": 0, "y": 23, "width": 6, "height": 3,
      "properties": {
        "title": "🔗 Current Connections",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # Connection Peak
    {
      "type": "metric", "x": 6, "y": 23, "width": 6, "height": 3,
      "properties": {
        "title": "🔺 Peak Connections",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Maximum", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # Free Storage
    {
      "type": "metric", "x": 12, "y": 23, "width": 6, "height": 3,
      "properties": {
        "title": "💿 Free Storage (GB)",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # Binary Log Usage
    {
      "type": "metric", "x": 18, "y": 23, "width": 6, "height": 3,
      "properties": {
        "title": "📋 Binary Logs (MB)",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "BinLogDiskUsage", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # Connection Trends
    {
      "type": "metric", "x": 0, "y": 26, "width": 12, "height": 8,
      "properties": {
        "title": "🔗 Connection Activity Pattern",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", local.identifier]
        ],
        "annotations": {
          "horizontal": [
            { "label": "🔴 HIGH USAGE", "value": 80, "color": "#d62728" },
            { "label": "🟡 WARNING", "value": 60, "color": "#ff7f0e" }
          ]
        }
      }
    },

    # Storage Trends
    {
      "type": "metric", "x": 12, "y": 26, "width": 12, "height": 8,
      "properties": {
        "title": "💿 Storage Capacity Trends",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", local.identifier],
          [".", "BinLogDiskUsage", ".", "."]
        ],
        "annotations": {
          "horizontal": [
            { "label": "🔴 STORAGE CRITICAL", "value": 10000000000, "color": "#d62728" },
            { "label": "🟡 WARNING", "value": 20000000000, "color": "#ff7f0e" }
          ]
        }
      }
    },

    # ===== I/O PERFORMANCE SECTION =====
    {
      "type": "text", "x": 0, "y": 30, "width": 24, "height": 1,
      "properties": {
        "markdown": "## ⚡ I/O Performance & Disk Health"
      }
    },

    # Read Latency
    {
      "type": "metric", "x": 0, "y": 31, "width": 6, "height": 3,
      "properties": {
        "title": "📖 Read Latency (ms)",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # Write Latency
    {
      "type": "metric", "x": 6, "y": 31, "width": 6, "height": 3,
      "properties": {
        "title": "✏️ Write Latency (ms)",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "WriteLatency", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # Queue Depth
    {
      "type": "metric", "x": 12, "y": 31, "width": 6, "height": 3,
      "properties": {
        "title": "📊 Queue Depth",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "DiskQueueDepth", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # IOPS Total
    {
      "type": "metric", "x": 18, "y": 31, "width": 6, "height": 3,
      "properties": {
        "title": "⚡ Total IOPS",
        "region": "eu-west-2", 
        "view": "singleValue",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "sparkline": true,
        "metrics": [["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", local.identifier]]
      }
    },

    # I/O Latency Trends
    {
      "type": "metric", "x": 0, "y": 34, "width": 12, "height": 4,
      "properties": {
        "title": "📀 I/O Latency Patterns",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", local.identifier],
          [".", "WriteLatency", ".", "."],
          [".", "DiskQueueDepth", ".", "."]
        ]
      }
    },

    # IOPS Trends
    {
      "type": "metric", "x": 12, "y": 34, "width": 12, "height": 4,
      "properties": {
        "title": "📈 IOPS Activity Patterns",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", local.identifier],
          [".", "WriteIOPS", ".", "."]
        ]
      }
    },

    # ===== NETWORK SECTION =====
    {
      "type": "text", "x": 0, "y": 38, "width": 24, "height": 1,
      "properties": {
        "markdown": "## 🌐 Network Performance"
      }
    },

    {
      "type": "metric", "x": 0, "y": 39, "width": 24, "height": 6,
      "properties": {
        "title": "🌐 Network Throughput Analysis",
        "region": "eu-west-2", 
        "view": "timeSeries",
        "stat": "Average", 
        "period": 300, 
        "liveData": true,
        "setPeriodToTimeRange": true,
        "yAxis": { "left": { "min": 0 } },
        "metrics": [
          ["AWS/RDS", "NetworkReceiveThroughput", "DBInstanceIdentifier", local.identifier],
          [".", "NetworkTransmitThroughput", ".", "."]
        ]
      }
    },
    # # ===== COSTS (AWS/Billing in us-east-1) =====
    # {
    #   "type": "text", "x": 0, "y": 45, "width": 24, "height": 1,
    #   "properties": {
    #     "markdown": "## 💰 Costs (Current Month)\nWidgets use **AWS/Billing** in **us-east-1**. For **last month**, change the dashboard time range to *Previous month*."
    #   }
    # },

    # # Account Total (Current Month)
    # {
    #   "type": "metric", "x": 0, "y": 46, "width": 8, "height": 4,
    #   "properties": {
    #     "title": "Account Total (Current Month)",
    #     "region": "us-east-1",
    #     "view": "singleValue",
    #     "stat": "Maximum",
    #     "setPeriodToTimeRange": true,
    #     "sparkline": false,
    #     "metrics": [
    #       ["AWS/Billing","EstimatedCharges","Currency","USD", "ServiceName","Amazon Relational Database Service"]
    #     ]
    #   }
    # },

    # # RDS Cost (Current Month)
    # {
    #   "type": "metric", "x": 8, "y": 46, "width": 8, "height": 4,
    #   "properties": {
    #     "title": "RDS Cost (Current Month)",
    #     "region": "us-east-1",
    #     "view": "singleValue",
    #     "stat": "Maximum",
    #     "setPeriodToTimeRange": true,
    #     "sparkline": false,
    #     "metrics": [
    #       ["AWS/Billing","EstimatedCharges","Currency","USD","ServiceName","Amazon Relational Database Service"]
    #     ]
    #   }
    # },

    # # (Optional) Leave a placeholder panel so the 3 tiles line up nicely
    # {
    #   "type": "text", "x": 16, "y": 46, "width": 8, "height": 4,
    #   "properties": {
    #     "markdown": " ",
    #     "background": "transparent"
    #   }
    # },

    # # Daily Cost Trend (under the numbers)
    # {
    #   "type": "metric", "x": 0, "y": 50, "width": 24, "height": 6,
    #   "properties": {
    #     "title": "Cost Over Time (Daily)",
    #     "region": "us-east-1",
    #     "view": "timeSeries",
    #     "stat": "Maximum",
    #     "period": 86400,
    #     "setPeriodToTimeRange": false,
    #     "metrics": [
    #       ["AWS/Billing","EstimatedCharges","Currency","USD", {"label":"Total"}],
    #       ["AWS/Billing","EstimatedCharges","Currency","USD","ServiceName","Amazon Relational Database Service", {"label":"RDS"}]
    #     ]
    #   }
    # },

    # ===== PERFORMANCE INSIGHTS INFO =====
    {
      "type": "text", "x": 0, "y": 50, "width": 24, "height": 2,
      "properties": {
        "markdown": "## 🔍 Performance Insights\n\n**📊 Advanced Query Analysis:** Access the RDS Console → Performance Insights tab for detailed query performance, wait events, and database load analysis. This provides query-level visibility beyond CloudWatch metrics."
      }
    },

    # ===== OPERATIONAL GUIDANCE =====
    {
      "type": "text", "x": 0, "y": 52, "width": 24, "height": 6,
      "properties": {
        "markdown": "## 🛠️ Troubleshooting Guide & Alerts\n\n**📢 Alert Configuration:** SNS Topic `RDSCloudWatchAlerts-${local.identifier}` | Evaluation: 2×5min periods\n\n### 🔧 Common Issue Patterns:\n• **🧠 CPU ↑ + 🔗 Connections ~** → Inefficient queries or missing indexes → Check slow query log & execution plans\n• **🧠 CPU ↑ + 💾 Memory ↓** → Memory pressure (temp tables, buffer pool) → Optimize memory settings or queries  \n• **🔗 Connections ↑ + ⏱️ Latency ↑** → Thread saturation → Implement connection pooling or increase limits\n• **📀 Latency ↑ + 📊 Queue Depth ↑** → Storage bottleneck → Increase IOPS/throughput or optimize I/O patterns\n• **💿 Free Storage ↓ / 📋 BinLog ↑** → Capacity issue → Expand storage, archive logs, or reduce retention period"
      }
    }
  ]
})
}
