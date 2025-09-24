resource "aws_cloudwatch_dashboard" "dms_dashboard" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      ### 🟢 Full Load Phase ###
      {
        "type" : "metric",
        "x" : 0, "y" : 0, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Full Load Throughput (Source vs Target)",
          "region" : local.region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DMS", "FullLoadThroughputRowsSource", "ReplicationTaskIdentifier", local.dms_task_name, "ReplicationInstanceIdentifier", local.dms_instance_id],
            [".", "FullLoadThroughputRowsTarget", ".", local.dms_task_name, ".", local.dms_instance_id]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 0, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Full Load Progress (%) & Latency",
          "region" : local.region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DMS", "FullLoadProgressPercent", "ReplicationTaskIdentifier", local.dms_task_name, "ReplicationInstanceIdentifier", local.dms_instance_id],
            [".", "FullLoadLatency", ".", local.dms_task_name, ".", local.dms_instance_id]
          ]
        }
      },

      ### 🔄 CDC Phase ###
      {
        "type" : "metric",
        "x" : 0, "y" : 6, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "CDC Latency (Source vs Target)",
          "region" : local.region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DMS", "CDCLatencySource", "ReplicationTaskIdentifier", local.dms_task_name, "ReplicationInstanceIdentifier", local.dms_instance_id],
            [".", "CDCLatencyTarget", ".", local.dms_task_name, ".", local.dms_instance_id],
            [".", "CDCLatencySourceMax", ".", local.dms_task_name, ".", local.dms_instance_id],
            [".", "CDCLatencyTargetMax", ".", local.dms_task_name, ".", local.dms_instance_id]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 6, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "CDC Throughput & Incoming Changes",
          "region" : local.region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DMS", "CDCThroughputRowsTarget", "ReplicationTaskIdentifier", local.dms_task_name, "ReplicationInstanceIdentifier", local.dms_instance_id],
            [".", "CDCIncomingChanges", ".", local.dms_task_name, ".", local.dms_instance_id]
          ]
        }
      },

      ### ⚠️ General Health / Errors ###
      {
        "type" : "metric",
        "x" : 0, "y" : 12, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Errors & Queue",
          "region" : local.region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DMS", "Errors", "ReplicationTaskIdentifier", local.dms_task_name, "ReplicationInstanceIdentifier", local.dms_instance_id],
            [".", "DiskQueueDepth", ".", local.dms_task_name, ".", local.dms_instance_id]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 12, "y" : 12, "width" : 12, "height" : 6,
        "properties" : {
          "title" : "Tables Processed",
          "region" : local.region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/DMS", "TotalTables", "ReplicationTaskIdentifier", local.dms_task_name, "ReplicationInstanceIdentifier", local.dms_instance_id],
            [".", "TablesCompleted", ".", local.dms_task_name, ".", local.dms_instance_id],
            [".", "ValidationFailedRecords", ".", local.dms_task_name, ".", local.dms_instance_id]
          ]
        }
      }
    ]
  })
}
