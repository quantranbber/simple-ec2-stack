resource "aws_autoscaling_group" "my_asg" {
  name                = "my_tf_asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = [aws_subnet.ec2_subnet1.id, aws_subnet.ec2_subnet2.id]
  health_check_type   = "EC2"
  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }
  initial_lifecycle_hook {
    name                 = "myprj-asg-hook"
    default_result       = "ABANDON"
    heartbeat_timeout    = 360
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_launch_template.my_launch_template, null_resource.build_image]
}

resource "aws_autoscaling_attachment" "my_asg_attachment" {
  lb_target_group_arn    = aws_lb_target_group.my_alb_tg.arn
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}

# wait for asg launch new instances, always triggers for new build
# resource "time_sleep" "wait_for_asg" {
#   lifecycle {
#     replace_triggered_by = [aws_autoscaling_group.my_asg]
#   }
#   create_duration = "360s"
# }