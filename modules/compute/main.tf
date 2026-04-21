# 1. Launch Template: The "Blueprint"
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-tpl-"
  image_id      = data.aws_ami.app_ami.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_endpoint = var.db_endpoint
  }))
}

# 2. Auto Scaling Group: The "Fleet Manager"
resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = var.private_subnets
  desired_capacity    = 2
  max_size            = 5
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}