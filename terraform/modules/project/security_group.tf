resource "aws_security_group" "my_security_group_1" {
  name        = "test-terraform-1"
  description = "my terraform sg creation"
  vpc_id      = aws_vpc.my_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "my_security_group_1_ingress" {
  security_group_id = aws_security_group.my_security_group_1.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "all"
}

resource "aws_vpc_security_group_egress_rule" "my_security_group_1_egress" {
  security_group_id = aws_security_group.my_security_group_1.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "all"
}