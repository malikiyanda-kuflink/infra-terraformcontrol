resource "aws_s3_bucket" "cicd_artifacts" {
  bucket = "test-kuflink-dev-laravel-pipeline-artifacts"

  lifecycle {
    prevent_destroy = false
  }

  # local-exec provisioner that empties the bucket
  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rm s3://${self.bucket} --recursive"
  }

  tags = {
    Name = "tf-kuflink-dev-laravel-pipeline-artifacts"
  }
}

resource "null_resource" "delete_s3_objects" {
  provisioner "local-exec" {
    command = "aws s3 rm s3://${aws_s3_bucket.cicd_artifacts.bucket} --recursive"
  }
}


#enabling versioning causing error leading to terraform loop trying to delete bucket that is not empty.

# resource "aws_s3_bucket_versioning" "cicd_artifacts_versioning" {
#   bucket = aws_s3_bucket.cicd_artifacts.bucket

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

