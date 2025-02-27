resource "aws_ecr_repository" "project_ecr_repository" {
  name                 = var.ecr_repo_name
  image_tag_mutability = var.project_image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.project_image_scan_on_push
  }

  force_delete = true

  tags = {
    Environment = var.environment
    Service     = "svc"
  }
}

# gran permissions to upload repository to ECR
# resource "aws_ecr_repository_policy" "project_ecr_repository" {
#   repository = aws_ecr_repository.project_ecr_repository.name
#   depends_on = [aws_ecr_repository.project_ecr_repository]
#   policy = jsondecode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "MannagedRepositoryContents",
#         "Action" : [
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:BatchDeleteImage",
#           "ecr:BatchGetImage",
#           "ecr:CompleteLayerUpload",
#           "ecr:DeleteRepository",
#           "ecr:DeleteRepositoryPolicy",
#           "ecr:DescribeRepositories",
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:GetRepositoryPolicy",
#           "ecr:InitiateLayerUpload",
#           "ecr:ListImage",
#           "ecr:PutImage",
#           "ecr:SetRepositoryPolicy",
#           "ecr:UploadLayerPart",
#         ],
#         "Principal" : {
#           "AWS" : [
#             "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#           ]
#         },
#         "Effect" : "Allow",
#       }
#     ]
#   })
# }

resource "null_resource" "build_image" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../../.."
    command     = "docker build -t ${var.ecr_repo_name} . && docker tag ${var.ecr_repo_name} ${aws_ecr_repository.project_ecr_repository.repository_url}:latest && docker push ${aws_ecr_repository.project_ecr_repository.repository_url}:latest"
  }

  depends_on = [aws_ecr_repository.project_ecr_repository, null_resource.get_cred_ecr_repository]
}


resource "null_resource" "get_cred_ecr_repository" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.default_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.default_region}.amazonaws.com"
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.project_ecr_repository.name
  depends_on = [aws_ecr_repository.project_ecr_repository]
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "delete old images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}