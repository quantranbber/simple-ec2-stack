resource "aws_subnet" "db_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.10.48/28"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "db_subnet1"
  }
}

resource "aws_subnet" "db_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.10.80/28"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "db_subnet2"
  }
}

resource "aws_route_table" "db_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "db_route_table"
  }
}

resource "aws_route_table_association" "eb_subnet_association1" {
  subnet_id      = aws_subnet.db_subnet1.id
  route_table_id = aws_route_table.db_route_table.id
}

resource "aws_route_table_association" "eb_subnet_association2" {
  subnet_id      = aws_subnet.db_subnet2.id
  route_table_id = aws_route_table.db_route_table.id
}