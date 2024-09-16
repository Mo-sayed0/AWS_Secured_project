
resource "aws_instance" "web_ec2" {
  count         = var.public_subnet_count
  ami           = data.aws_ami.image.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnets[count.index].id
  connection {
    type = "ssh"
    user = "ec2-user"
    host = self.private_ip
  }
  user_data              = filebase64("${path.module}/script1.sh")
  vpc_security_group_ids = [aws_security_group.sg_web.id]

  tags = {
    Name = "HA-web-${count.index}"
  }
}

resource "aws_instance" "app_ec2" {
  count         = var.private_subnet_count >= 2 ? 2 : 0
  ami           = data.aws_ami.image.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnets[count.index].id
  connection {
    type = "ssh"
    user = "ec2-user"
    host = self.private_ip
  }
  user_data              = filebase64("${path.module}/script1.sh")
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  tags = {
    Name = "HA-app-${count.index}"
  }
}
