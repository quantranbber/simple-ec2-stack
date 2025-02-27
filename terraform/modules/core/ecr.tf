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