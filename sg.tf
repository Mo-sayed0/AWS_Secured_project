
# Security Groups
resource "aws_security_group" "sg_web" {
  name        = "webserver"
  description = "Security Group for Web Servers"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = [80, 443, 22]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = local.egress_web
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "HA_sg-web"
  }
}

resource "aws_security_group" "sg_app" {
  name   = "appserver"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web.id]
  }
  ingress {
    description     = "SSH from public subnets"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_web.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "HA_sg-app"
  }
}

resource "aws_security_group" "sg_db" {
  name   = "database"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = local.egress_db
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.sg_app.id]
    }
  }

  dynamic "egress" {
    for_each = local.egress_db
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "HA_sg-db"
  }
}

