resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "my-tf-template-"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/userdata.sh"))
  key_name      = data.aws_key_pair.terraform_key_pair.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.my_security_group_1.id]
  }
  lifecycle {
    create_before_destroy = true
  }
}