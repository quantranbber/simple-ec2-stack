resource "null_resource" "build_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../../.."
    command     = "docker build -t ${var.ecr_repo_name} . && docker tag ${var.ecr_repo_name} ${var.ecr_repository_url}:latest && docker push ${var.ecr_repository_url}:latest"
  }

  depends_on = [null_resource.get_cred_ecr_repository]
}


resource "null_resource" "get_cred_ecr_repository" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.default_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.default_region}.amazonaws.com"
  }
}

# update ec2 docker containers without terminate asg
resource "null_resource" "send_ssm_command" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [aws_lb.my_alb, null_resource.build_image]

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command     = "sh ${path.module}/build.sh"
    environment = {
      REGION   = var.default_region
      ALB_DNS  = aws_lb.my_alb.dns_name
      ASG_NAME = aws_autoscaling_group.my_asg.name
    }
  }
}

# wait ssm send command run success
# resource "time_sleep" "wait_for_update_img" {
#   lifecycle {
#     replace_triggered_by = [null_resource.send_ssm_command]
#   }
#   create_duration = "360s"
# }