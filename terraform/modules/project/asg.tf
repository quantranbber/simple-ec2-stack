resource "aws_autoscaling_group" "my_asg" {
  name = "my_asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
  lifecycle {
    replace_triggered_by = [ aws_launch_template.my_launch_template ]
  }
}

resource "aws_autoscaling_attachment" "my_asg_attachment" {
  lb_target_group_arn    = aws_lb_target_group.my_alb_tg.arn
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}