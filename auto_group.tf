
# Launch Templates
resource "aws_launch_template" "web_launch_template" {
  count                  = var.public_subnet_count
  name_prefix            = "web-launch-template-${count.index + 1}"
  image_id               = data.aws_ami.image.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  user_data              = base64encode(file("${path.module}/script1.sh"))
  key_name               = var.key_name
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
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  user_data              = base64encode(file("${path.module}/script1.sh"))
  key_name               = var.key_name
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "HA-app-${count.index + 1}"
    }
  }
}

# Auto Scaling Groups
resource "aws_autoscaling_group" "web_asg" {
  count                     = var.public_subnet_count
  name                      = "web-asg-${count.index + 1}"
  vpc_zone_identifier       = [aws_subnet.public_subnets[count.index].id]
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.public_tg.arn]
  metrics_granularity       = "5Minute"
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
  count                     = var.private_subnet_count
  name                      = "app-asg-${count.index + 1}"
  vpc_zone_identifier       = [aws_subnet.private_subnets[count.index].id]
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.private_tg.arn]
  metrics_granularity       = "5Minute"
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

resource "aws_autoscaling_policy" "Target_policy" {
  count                  = var.public_subnet_count
  name                   = "web-target-policy-${count.index + 1}"
  autoscaling_group_name = aws_autoscaling_group.web_asg[count.index].name
  adjustment_type        = "PercentChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 20
    customized_metric_specification {
      metrics {
        label = "alarm Averger network traffic"
        id    = "m1"
        metric_stat {
          metric {
            namespace   = "AWS/AutoScaling"
            metric_name = "NetworkIn"
            dimensions {
              name  = "AutoScalingGroupName"
              value = " terraform-2024090614450661840000000c"
            }
          }
          stat = "Average"
        }
        return_data = true
      }
    }
  }

}

resource "aws_cloudwatch_metric_alarm" "alarm_target" {
  count               = var.public_subnet_count
  alarm_name          = "alarm-target"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "This metric monitors auroscaling NetworkIn"
  dimensions = {
    TargetGroup  = aws_lb_target_group.public_tg.arn_suffix
    LoadBalancer = aws_lb.public_alb.arn_suffix
  }
  alarm_actions             = [aws_autoscaling_policy.Target_policy[count.index].arn]
  insufficient_data_actions = []
}

resource "aws_autoscaling_policy" "Target_policy2" {
  count                  = var.private_subnet_count >= 2 ? 2 : 0
  name                   = "app-target-policy-${count.index + 1}"
  autoscaling_group_name = aws_autoscaling_group.app_asg[count.index].name
  adjustment_type        = "PercentChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 20
    customized_metric_specification {
      metrics {
        label = "alarm Averger network traffic"
        id    = "m1"
        metric_stat {
          metric {
            namespace   = "AWS/AutoScaling"
            metric_name = "NetworkIn"
            dimensions {
              name  = "AutoScalingGroupName"
              value = " terraform-2024090614450661840000000c"
            }
          }
          stat = "Average"
        }
        return_data = true
      }
    }
  }

}

resource "aws_cloudwatch_metric_alarm" "alarm_target2" {
  count               = var.private_subnet_count >= 2 ? 2 : 0
  alarm_name          = "alarm-target"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "This metric monitors auroscaling NetworkIn"
  dimensions = {
    TargetGroup  = aws_lb_target_group.private_tg.arn_suffix
    LoadBalancer = aws_lb.private_alb.arn_suffix
  }
  alarm_actions             = [aws_autoscaling_policy.Target_policy2[count.index].arn]
  insufficient_data_actions = []
}
