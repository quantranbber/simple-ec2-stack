resource "aws_lb" "my_alb" {
  name               = "my-tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.lb_subnet1.id, aws_subnet.lb_subnet2.id]
}