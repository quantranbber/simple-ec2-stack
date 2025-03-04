terraform {
  required_version = "1.9.8"
  backend "s3" {
    bucket = ""
    key    = ""
    region = ""
  }
}

provider "aws" {
  region = var.default_region
}

module "core" {
  source         = "./modules/core"
  db_name        = var.db_name
  db_user        = var.db_user
  default_region = var.default_region
  ecr_repo_name  = var.ecr_repo_name
  environment    = var.environment
  s3_bucket      = var.artifact_bucket
}

module "project" {
  source             = "./modules/project"
  instance_type      = var.instance_type
  artifact_bucket    = var.artifact_bucket
  ecr_repo_name      = var.ecr_repo_name
  environment        = var.environment
  default_region     = var.default_region
  ecr_repository_url = module.core.ecr_repository_url
  vpc_id             = module.core.vpc_id
  db_sg_id           = module.core.db_sg_id
  alb_dns            = module.core.alb_dns
  alb_arn            = module.core.alb_arn
  alb_sg_id          = module.core.alb_sg_id
  nat_gtw_id         = module.core.nat_gtw_id

  depends_on = [module.core]
}

output "alb_url" {
  description = "The ALB URL"
  value       = "http://${module.core.alb_dns}"
}