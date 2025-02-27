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

# TODO
resource "null_resource" "send_ssm_command" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [null_resource.build_image]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "sh ${path.module}/build.sh"
    environment = {
      REGION   = var.default_region
      ASG_NAME = aws_autoscaling_group.my_asg.name
    }
  }
}
