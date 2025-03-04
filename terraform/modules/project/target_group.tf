resource "aws_lb_target_group" "my_alb_tg" {
  name                          = "my-tf-test-tg"
  port                          = 3000
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    protocol            = "HTTP"
    port                = "3000"
    path                = "/health"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    replace_triggered_by = [aws_autoscaling_group.my_asg]
  }
  depends_on = [aws_autoscaling_group.my_asg]
}

resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = var.alb_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.my_alb_tg.arn
      }
    }
  }

  lifecycle {
    replace_triggered_by = [aws_lb_target_group.my_alb_tg]
  }
  depends_on = [aws_lb_target_group.my_alb_tg]
}