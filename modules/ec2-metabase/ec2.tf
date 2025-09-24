# EC2 Instance with Provisioners

resource "aws_instance" "kuflink_ec2" {
  ami = var.metabase_ami
  # ami                    = "ami-05a1ad59068236013"
  instance_type = var.metabase_instance_type
  key_name      = var.StagingsKeyPair
  subnet_id     = element(var.private_subnet_ids, 1) # selects the thrid subnet
  monitoring    = true                               # Enables detailed monitoring at 1-minute intervals
  # associate_public_ip_address = true

  vpc_security_group_ids = [var.metabase_sg_id]

  root_block_device {
    volume_size = 120
  }

  user_data            = file("${path.module}/ec2-user-data.sh")
  iam_instance_profile = var.metabase_ec2_instance_profile_name

  tags = {
    Name        = var.instance_name,
    Application = var.instance_name,
    Environment = "Test"
  }

}