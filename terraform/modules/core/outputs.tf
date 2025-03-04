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

output "alb_dns" {
  description = "ALB dns name"
  value       = aws_lb.my_alb.dns_name
}

output "alb_arn" {
  description = "ALB arn"
  value       = aws_lb.my_alb.arn
}

output "alb_sg_id" {
  description = "ALB security group id"
  value       = aws_security_group.lb_sg.id
}

output "nat_gtw_id" {
  description = "NAT gateway id"
  value       = aws_nat_gateway.my_nat_gtw.id
}