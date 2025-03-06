output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.my_vpc.id
}

output "ecr_repository_url" {
  description = "ECR repository url"
  value       = aws_ecr_repository.project_ecr_repository.repository_url
}

output "alb_dns" {
  description = "ALB dns name"
  value       = aws_lb.my_alb.dns_name
}

output "alb_arn" {
  description = "ALB arn"
  value       = aws_lb.my_alb.arn
}

output "ec2_sg_id" {
  description = "EC2 security group id"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_subnet1_id" {
  description = "EC2 subnet1 id"
  value       = aws_subnet.ec2_subnet1.id
}

output "ec2_subnet2_id" {
  description = "EC2 subnet2 id"
  value       = aws_subnet.ec2_subnet2.id
}