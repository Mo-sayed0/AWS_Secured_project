# Public ALB
resource "aws_lb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_web.id]
  subnets            = slice(aws_subnet.public_subnets[*].id, 0, min(length(var.availability_zones), var.public_subnet_count))

  enable_deletion_protection = false

  tags = {
    Name = "HA_Public-ALB"
  }
}

resource "aws_lb_target_group" "public_tg" {
  name     = "public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "public_tg_attachment" {
  count            = length(aws_instance.web_ec2)
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = aws_instance.web_ec2[count.index].id
  port             = 80
}

# Private ALB
resource "aws_lb" "private_alb" {
  name               = "private-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_app.id]
  subnets            = slice(aws_subnet.private_subnets[*].id, 0, min(length(var.availability_zones), var.private_subnet_count))

  enable_deletion_protection = false

  tags = {
    Name = "HA_Private-ALB"
  }
}

resource "aws_lb_target_group" "private_tg" {
  name     = "private-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "private_listener" {
  load_balancer_arn = aws_lb.private_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "private_tg_attachment" {
  count            = length(aws_instance.app_ec2)
  target_group_arn = aws_lb_target_group.private_tg.arn
  target_id        = aws_instance.app_ec2[count.index].id
  port             = 80
}

