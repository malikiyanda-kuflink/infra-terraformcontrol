variable "backup_role_name" {
  description = "Name for the Backup IAM Role"
  type        = string
}

variable "ec2_test_instance_role_name" {
  description = "Name for the EC2 Test Instance Role"
  type        = string
}

variable "lambda_role_name" {
  description = "Name for the Lambda IAM Role"
  type        = string
}

variable "eb_role_name" {
  description = "Name for the Elasticbeanstalk IAM Role"
  type        = string
}


variable "eb_instance_profile_name" {
  description = "Name for the Elasticbeanstalk Instance Profile"
  type        = string
}

variable "test_redis_instance_role" {
  description = "Name for the Redis Instance Role"
  type        = string 
}


variable "tags" {
  description = "Tags to apply to IAM roles"
  type        = map(string)
}
