output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.my_vpc.id
}

output "ecr_repository_url" {
  description = "ECR repository url"
  value       = aws_ecr_repository.project_ecr_repository.repository_url
}

output "db_sg_id" {
  description = "DB security group"
  value       = aws_security_group.db_sg.id
}