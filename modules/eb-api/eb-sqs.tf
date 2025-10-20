# =================================================================================================
# SQS Queue
# =================================================================================================
resource "aws_sqs_queue" "worker_queue" {
  name                       = var.aws_sqs_queue_name
  visibility_timeout_seconds = var.sqsd_visibility_timeout
  tags                       = var.tags

  lifecycle {
    prevent_destroy = false
  }
}
