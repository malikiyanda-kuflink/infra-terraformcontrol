# resource "aws_cloudwatch_dashboard" "rds_query_analysis" {
#   dashboard_name = "RDS-Query-Analysis-${local.rds_db_id}"

#   dashboard_body = jsonencode({
#     widgets = [
#       # ===== HEADER =====
#       {
#         "type": "text", "x": 0, "y": 0, "width": 24, "height": 3,
#         "properties": {
#           "markdown": "# 🔍 RDS Query Analysis Dashboard\n## Database: ${local.rds_db_id}\n\n**🚀 For detailed query analysis:** [Performance Insights Console](https://console.aws.amazon.com/rds/home?region=eu-west-2#performance-insights-v20206:resourceId=${local.rds_db_id})"
#         }
#       },

#       # ===== DATABASE LOAD SECTION =====
#       {
#         "type": "text", "x": 0, "y": 3, "width": 24, "height": 1,
#         "properties": {
#           "markdown": "## 📊 Database Load & Active Sessions"
#         }
#       },

#       # Total Database Load
#       {
#         "type": "metric", "x": 0, "y": 4, "width": 8, "height": 4,
#         "properties": {
#           "title": "📈 Total Database Load",
#           "region": "eu-west-2",
#           "view": "singleValue",
#           "stat": "Average",
#           "period": 300,
#           "sparkline": true,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "metrics": [["AWS/RDS", "DBLoad", "DBInstanceIdentifier", local.rds_db_id]]
#         }
#       },

#       # CPU Load
#       {
#         "type": "metric", "x": 8, "y": 4, "width": 8, "height": 4,
#         "properties": {
#           "title": "🧠 CPU-Related Load",
#           "region": "eu-west-2",
#           "view": "singleValue",
#           "stat": "Average",
#           "period": 300,
#           "sparkline": true,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "metrics": [["AWS/RDS", "DBLoadCPU", "DBInstanceIdentifier", local.rds_db_id]]
#         }
#       },

#       # Non-CPU Load
#       {
#         "type": "metric", "x": 16, "y": 4, "width": 8, "height": 4,
#         "properties": {
#           "title": "💾 I/O & Wait Load",
#           "region": "eu-west-2",
#           "view": "singleValue",
#           "stat": "Average",
#           "period": 300,
#           "sparkline": true,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "metrics": [["AWS/RDS", "DBLoadNonCPU", "DBInstanceIdentifier", local.rds_db_id]]
#         }
#       },

#       # Database Load Trends
#       {
#         "type": "metric", "x": 0, "y": 8, "width": 24, "height": 8,
#         "properties": {
#           "title": "📊 Database Load Breakdown - Active Sessions by Wait Type",
#           "region": "eu-west-2",
#           "view": "timeSeries",
#           "stat": "Average",
#           "period": 300,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "yAxis": { "left": { "min": 0 } },
#           "metrics": [
#             ["AWS/RDS", "DBLoad", "DBInstanceIdentifier", local.rds_db_id, { "label": "Total Load" }],
#             [".", "DBLoadCPU", ".", ".", { "label": "CPU Load" }],
#             [".", "DBLoadNonCPU", ".", ".", { "label": "I/O + Wait Load" }]
#           ],
#           "annotations": {
#             "horizontal": [
#               { "label": "🔴 HIGH LOAD", "value": 4, "color": "#d62728" },
#               { "label": "🟡 MODERATE LOAD", "value": 2, "color": "#ff7f0e" }
#             ]
#           }
#         }
#       },

#       # ===== QUERY PERFORMANCE INDICATORS =====
#       {
#         "type": "text", "x": 0, "y": 16, "width": 24, "height": 1,
#         "properties": {
#           "markdown": "## ⚡ Query Performance Indicators"
#         }
#       },

#       # Read Latency
#       {
#         "type": "metric", "x": 0, "y": 17, "width": 6, "height": 4,
#         "properties": {
#           "title": "📖 Query Read Latency",
#           "region": "eu-west-2",
#           "view": "singleValue",
#           "stat": "Average",
#           "period": 300,
#           "sparkline": true,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "metrics": [["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", local.rds_db_id]]
#         }
#       },

#       # Write Latency
#       {
#         "type": "metric", "x": 6, "y": 17, "width": 6, "height": 4,
#         "properties": {
#           "title": "✏️ Query Write Latency",
#           "region": "eu-west-2",
#           "view": "singleValue",
#           "stat": "Average",
#           "period": 300,
#           "sparkline": true,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "metrics": [["AWS/RDS", "WriteLatency", "DBInstanceIdentifier", local.rds_db_id]]
#         }
#       },

#       # Queue Depth
#       {
#         "type": "metric", "x": 12, "y": 17, "width": 6, "height": 4,
#         "properties": {
#           "title": "📊 Query Queue Depth",
#           "region": "eu-west-2",
#           "view": "singleValue",
#           "stat": "Average",
#           "period": 300,
#           "sparkline": true,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "metrics": [["AWS/RDS", "DiskQueueDepth", "DBInstanceIdentifier", local.rds_db_id]]
#         }
#       },

#       # Active Connections
#       {
#         "type": "metric", "x": 18, "y": 17, "width": 6, "height": 4,
#         "properties": {
#           "title": "🔗 Active Query Sessions",
#           "region": "eu-west-2",
#           "view": "singleValue",
#           "stat": "Average",
#           "period": 300,
#           "sparkline": true,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", local.rds_db_id]]
#         }
#       },

#       # Query Performance Trends
#       {
#         "type": "metric", "x": 0, "y": 21, "width": 24, "height": 8,
#         "properties": {
#           "title": "⚡ Query Performance Trends",
#           "region": "eu-west-2",
#           "view": "timeSeries",
#           "stat": "Average",
#           "period": 300,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "yAxis": { "left": { "min": 0 } },
#           "metrics": [
#             ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", local.rds_db_id, { "label": "Read Latency (ms)" }],
#             [".", "WriteLatency", ".", ".", { "label": "Write Latency (ms)" }],
#             [".", "DiskQueueDepth", ".", ".", { "label": "Queue Depth" }]
#           ]
#         }
#       },

#       # ===== QUERY VOLUME & PATTERNS =====
#       {
#         "type": "text", "x": 0, "y": 29, "width": 24, "height": 1,
#         "properties": {
#           "markdown": "## 📈 Query Volume & I/O Patterns"
#         }
#       },

#       # Read IOPS
#       {
#         "type": "metric", "x": 0, "y": 30, "width": 12, "height": 6,
#         "properties": {
#           "title": "📖 Read Query Volume (IOPS)",
#           "region": "eu-west-2",
#           "view": "timeSeries",
#           "stat": "Average",
#           "period": 300,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "yAxis": { "left": { "min": 0 } },
#           "metrics": [
#             ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", local.rds_db_id, { "stat": "Average", "label": "Avg Read IOPS" }],
#             ["...", { "stat": "Maximum", "label": "Peak Read IOPS" }]
#           ]
#         }
#       },

#       # Write IOPS
#       {
#         "type": "metric", "x": 12, "y": 30, "width": 12, "height": 6,
#         "properties": {
#           "title": "✏️ Write Query Volume (IOPS)",
#           "region": "eu-west-2",
#           "view": "timeSeries",
#           "stat": "Average",
#           "period": 300,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "yAxis": { "left": { "min": 0 } },
#           "metrics": [
#             ["AWS/RDS", "WriteIOPS", "DBInstanceIdentifier", local.rds_db_id, { "stat": "Average", "label": "Avg Write IOPS" }],
#             ["...", { "stat": "Maximum", "label": "Peak Write IOPS" }]
#           ]
#         }
#       },

#       # ===== SLOW QUERY INDICATORS =====
#       {
#         "type": "text", "x": 0, "y": 36, "width": 24, "height": 1,
#         "properties": {
#           "markdown": "## 🐌 Slow Query Indicators"
#         }
#       },

#       # CPU vs I/O Load Comparison
#       {
#         "type": "metric", "x": 0, "y": 37, "width": 12, "height": 6,
#         "properties": {
#           "title": "🧠 CPU vs 💾 I/O Load Comparison",
#           "region": "eu-west-2",
#           "view": "timeSeries",
#           "stat": "Average",
#           "period": 300,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "yAxis": { "left": { "min": 0 } },
#           "metrics": [
#             ["AWS/RDS", "DBLoadCPU", "DBInstanceIdentifier", local.rds_db_id, { "label": "CPU-bound queries" }],
#             [".", "DBLoadNonCPU", ".", ".", { "label": "I/O-bound queries" }]
#           ]
#         }
#       },

#       # Memory Pressure Indicator
#       {
#         "type": "metric", "x": 12, "y": 37, "width": 12, "height": 6,
#         "properties": {
#           "title": "💾 Memory Pressure & Query Impact",
#           "region": "eu-west-2",
#           "view": "timeSeries",
#           "stat": "Average",
#           "period": 300,
#           "liveData": true,
#           "setPeriodToTimeRange": true,
#           "yAxis": { "left": { "min": 0 } },
#           "metrics": [
#             ["AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", local.rds_db_id, { "label": "Available Memory" }],
#             [".", "SwapUsage", ".", ".", { "label": "Swap Usage" }]
#           ]
#         }
#       },

#       # ===== PERFORMANCE INSIGHTS INTEGRATION =====
#       {
#         "type": "text", "x": 0, "y": 43, "width": 24, "height": 4,
#         "properties": {
#           "markdown": "## 🔍 Detailed Query Analysis\n\n**For specific query details, use Performance Insights:**\n\n• **Top Queries by CPU** - Identify resource-intensive queries\n• **Wait Events Analysis** - Understand what queries are waiting for\n• **Query Execution Plans** - Analyze query optimization opportunities\n• **Real-time Query Monitoring** - See currently executing queries\n\n**📱 Quick Access Links:**\n• [Performance Insights Console](https://console.aws.amazon.com/rds/home?region=eu-west-2#performance-insights-v20206:resourceId=${local.rds_db_id})\n• [RDS Console Monitoring](https://console.aws.amazon.com/rds/home?region=eu-west-2#database:id=${local.rds_db_id};is-cluster=false;tab=monitoring)"
#         }
#       },

#       # ===== TROUBLESHOOTING GUIDE =====
#       {
#         "type": "text", "x": 0, "y": 47, "width": 24, "height": 6,
#         "properties": {
#           "markdown": "## 🛠️ Query Performance Troubleshooting\n\n### 🔍 Investigation Patterns:\n\n• **High DBLoad + High CPU Load** → CPU-intensive queries (complex calculations, missing indexes)\n• **High DBLoad + High I/O Load** → I/O-bound queries (large table scans, insufficient memory)\n• **High Read Latency + High IOPS** → Storage bottleneck, consider provisioned IOPS\n• **High Queue Depth + Normal IOPS** → Query concurrency issues, review connection pooling\n• **High Memory Usage + High I/O** → Insufficient buffer pool, consider memory optimization\n\n### 📊 Next Steps for Analysis:\n1. **Use Performance Insights** for query-level details\n2. **Enable slow query log** for historical analysis\n3. **Review execution plans** for optimization opportunities\n4. **Check indexes** for frequently accessed tables"
#         }
#       }
#     ]
#   })
# }