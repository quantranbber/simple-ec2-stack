resource "aws_lb" "my_alb" {
  name               = "my-tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group_1.id]
  subnets            = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]
}

resource "aws_lb_target_group" "my_alb_tg" {
  name                          = "my-tf-test-tg"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = aws_vpc.my_vpc.id
  load_balancing_algorithm_type = "round_robin"
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
}