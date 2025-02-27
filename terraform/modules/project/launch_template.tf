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
    security_groups             = [aws_security_group.ec2_sg.id]
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_db_instance.rds_postgres, null_resource.build_image]
}

resource "time_sleep" "wait_time" {
  depends_on      = [aws_launch_template.my_launch_template]
  create_duration = "120s"
}