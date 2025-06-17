resource "aws_sqs_queue" "worker_queue" {
  name = "test-kuflink-dev-queue"

  tags ={
      Description = "ElasticBeanstalk Worker Queue for Kuflink-PHP-API"
  }


  lifecycle {
    prevent_destroy = false
  }
}
