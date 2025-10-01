resource "aws_s3_bucket" "dms_assessment_results" {
  bucket        = "dms-${var.name_prefix}-assessment-results"
  force_destroy = true
  tags = { Name = "dms-${var.name_prefix}-Assessment-Results-Bucket"
  }
}
