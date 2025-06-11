resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux_2.id
  subnet_id     = var.public_subnet_id
  security_groups = [aws_security_group.bastion_sg.id]
  instance_type = var.instance_type
  key_name      = var.ssh_key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name
  user_data = file("${path.module}/ec2-user-data.sh")


  tags = {
    Name = var.bastion_name
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


