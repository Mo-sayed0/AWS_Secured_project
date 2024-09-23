
# Launch Templates
resource "aws_launch_template" "web_launch_template" {
  count                  = var.public_subnet_count
  name_prefix            = "web-launch-template-${count.index + 1}"
  image_id               = data.aws_ami.image.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  user_data              = base64encode(file("${path.module}/script1.sh"))
  key_name               = "Terraform-project" 

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "HA-web-${count.index + 1}"
    }
  }
}

resource "aws_launch_template" "app_launch_template" {
  count                  = var.private_subnet_count
  name_prefix            = "app-launch-template-${count.index + 1}"
  image_id               = data.aws_ami.image.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_app.id]
  key_name               = "Terraform-project" 

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "HA-app-${count.index + 1}"
    }
  }
}

# Auto Scaling Groups
resource "aws_autoscaling_group" "web_asg" {
  count               = var.public_subnet_count
  name                = "web-asg-${count.index + 1}"
  vpc_zone_identifier = aws_subnet.public_subnets[*].id
  desired_capacity    = 1
  min_size            = 1
  max_size            = 4
  target_group_arns   = [aws_lb_target_group.public_tg.arn]

  launch_template {
    id      = aws_launch_template.web_launch_template[count.index].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "HA-web-${count.index + 1}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  count               = var.private_subnet_count
  name                = "app-asg-${count.index + 1}"
  vpc_zone_identifier = aws_subnet.private_subnets[*].id
  desired_capacity    = 1
  min_size            = 1
  max_size            = 4
  target_group_arns   = [aws_lb_target_group.private_tg.arn]

  launch_template {
    id      = aws_launch_template.app_launch_template[count.index].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "HA-app-${count.index + 1}"
    propagate_at_launch = true
  }
}

