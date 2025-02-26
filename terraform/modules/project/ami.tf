data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_key_pair" "terraform_key_pair" {
  key_name = "terraform_key"
}

# resource "aws_instance" "my_ec2_instance" {
#   ami                         = data.aws_ami.latest_amazon_linux.id
#   instance_type               = "t2.micro"
#   user_data                   = file("userdata.sh")
#   key_name                    = data.aws_key_pair.terraform_key_pair.key_name
#   associate_public_ip_address = true
#   security_groups             = [aws_security_group.my_security_group_1.id]
#   subnet_id                   = aws_subnet.my_subnet_1.id

#   tags = {
#     Name = "test-terraform-instance"
#   }
# }