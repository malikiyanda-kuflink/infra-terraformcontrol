# EC2 Instance
resource "aws_instance" "test_instance" {
  ami = data.aws_ami.amazon_linux_2023.id

  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.test_instance_sg_id]
  key_name               = var.ssh_key_name
  user_data              = file("${path.module}/ec2-user-data.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2_test_instance_profile.name
  # associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}

resource "aws_eip" "test_instance_eip" {
  tags = {
    Name = "${var.instance_name}-eip"
  }
}

resource "aws_eip_association" "test_instance_assoc" {
  instance_id   = aws_instance.test_instance.id
  allocation_id = aws_eip.test_instance_eip.id
}



# Fetch latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# Fetch latest Amazon Linux 2 AMI
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
