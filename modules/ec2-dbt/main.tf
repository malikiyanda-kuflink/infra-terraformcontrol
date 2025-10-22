resource "aws_instance" "dbt_host" {
  ami                         = data.aws_ami.ubuntu_2204.id
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.dbt_sg_id]
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false
  iam_instance_profile        = var.dbt_instance_profile_name




  # 👇 required so the script can read tags from IMDS
  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  # static file, no interpolation
  user_data = var.dbt_user_data

  tags = merge(
    { Name = var.dbt_name },
    var.instance_tags
  )

}

# Canonical's AWS account ID is 099720109477
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = [var.canonical_id]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

