resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.10.0/24"

  tags = {
    Name = "tf-example"
  }
}