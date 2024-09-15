data "aws_ami" "image" {
  most_recent = true
  filter {
    name = "name"
    values = [ "al2023-ami*" ]
  }
  filter {
  name   = "virtualization-type"
  values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

 }
