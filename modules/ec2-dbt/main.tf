resource "aws_instance" "dbt_host" {
  ami                         = data.aws_ami.ubuntu_2204.id
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.dbt_sg_id]
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  associate_public_ip_address = false
  iam_instance_profile        = var.dbt_instance_profile_name

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_type == "gp3" || var.root_volume_type == "io1" || var.root_volume_type == "io2" ? var.root_volume_iops : null
    throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
    delete_on_termination = var.root_volume_delete_on_termination
    encrypted             = var.root_volume_encrypted
    kms_key_id            = var.root_volume_kms_key_id  # null = AWS managed key, or provide custom KMS key ARN
    
    tags = {
      Name        = "${var.dbt_name}-Root"
      Environment = var.environment
      VolumeType  = "root"
      ManagedBy   = "terraform"
    }
  }

  # 👇 required so the script can read tags from IMDS
  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  # static file
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

