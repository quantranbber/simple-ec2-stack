resource "aws_subnet" "ec2_subnet1" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.10.16/28"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "ec2_subnet1"
  }
}

resource "aws_subnet" "ec2_subnet2" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.10.32/28"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "ec2_subnet2"
  }
}

resource "aws_route_table" "ec2_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gtw_id
  }

  tags = {
    Name = "ec2_route_table"
  }
}

resource "aws_route_table_association" "ec2_subnet_association1" {
  subnet_id      = aws_subnet.ec2_subnet1.id
  route_table_id = aws_route_table.ec2_route_table.id
}

resource "aws_route_table_association" "ec2_subnet_association2" {
  subnet_id      = aws_subnet.ec2_subnet2.id
  route_table_id = aws_route_table.ec2_route_table.id
}