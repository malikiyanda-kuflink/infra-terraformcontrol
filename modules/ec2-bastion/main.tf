resource "aws_instance" "bastion_host" {
  ami                         = var.bastion_ami_id
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  instance_type               = var.instance_type
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  iam_instance_profile        = var.bastion_instance_profile_name


  # 👇 required so the script can read tags from IMDS
  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  # static file, no interpolation
  user_data = var.bastion_user_data

  tags = merge(
    { Name = var.bastion_name },
    var.instance_tags
  )
}
