resource "aws_subnet" "lb_subnet1" {
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.10.0/28"
  availability_zone       = "ap-southeast-1a"
  tags = {
    Name = "lb_subnet1"
  }
}

resource "aws_subnet" "lb_subnet2" {
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.10.64/28"
  availability_zone       = "ap-southeast-1b"
  tags = {
    Name = "lb_subnet2"
  }
}

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

resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = "tf-example-igw-1"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my_nat_gtw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.lb_subnet1.id
}

resource "aws_route_table" "alb_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }

  tags = {
    Name = "alb_route_table"
  }
}

resource "aws_route_table" "ec2_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gtw.id
  }

  tags = {
    Name = "ec2_route_table"
  }
}

resource "aws_route_table_association" "alb_subnet_association1" {
  subnet_id      = aws_subnet.lb_subnet1.id
  route_table_id = aws_route_table.alb_route_table.id
}

resource "aws_route_table_association" "alb_subnet_association2" {
  subnet_id      = aws_subnet.lb_subnet2.id
  route_table_id = aws_route_table.alb_route_table.id
}

resource "aws_route_table_association" "ec2_subnet_association1" {
  subnet_id      = aws_subnet.ec2_subnet1.id
  route_table_id = aws_route_table.ec2_route_table.id
}

resource "aws_route_table_association" "ec2_subnet_association2" {
  subnet_id      = aws_subnet.ec2_subnet2.id
  route_table_id = aws_route_table.ec2_route_table.id
}