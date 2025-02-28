resource "aws_lb" "my_alb" {
  name               = "my-tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.lb_subnet1.id, aws_subnet.lb_subnet2.id]
}

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
    interval            = 300
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    replace_triggered_by = [aws_autoscaling_group.my_asg]
  }
  depends_on = [time_sleep.wait_for_asg, time_sleep.wait_for_update_img]
}

resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
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