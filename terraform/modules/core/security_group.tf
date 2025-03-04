# db
resource "aws_security_group" "db_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  name_prefix = "db-sg"
}

resource "aws_vpc_security_group_egress_rule" "db_sg_egress" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "all"
}

# alb
resource "aws_security_group" "lb_sg" {
  vpc_id      = aws_vpc.my_vpc.id
  name_prefix = "alb-sg"
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_ingress" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "lb_sg_egress" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "all"
}