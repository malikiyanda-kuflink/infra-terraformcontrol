resource "aws_instance" "redis_host" {
  # ami                         = data.aws_ami.amazon_linux_2.id
  ami                         = var.redis_ami_id
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.redis_sg_id]
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.redis_instance_profile_name



  # 👇 required so the script can read tags from IMDS
  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  # static file, no interpolation
  user_data                   = var.redis_user_data
  user_data_replace_on_change = var.redis_user_data_replace_on_change
  tags                        = { Name = var.redis_name }
}

# ssm-redis-host.tf
resource "aws_ssm_parameter" "redis_host_ssm_param" {
  name      = var.redis_host_param_name
  type      = "String"
  value     = aws_instance.redis_host.private_ip
  overwrite = true
}

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }


