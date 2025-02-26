terraform {
  required_version = "1.9.8"
  backend "s3" {
    bucket = ""
    key = ""
    region = ""
  }
}

provider "aws" {
  region = var.default_region
}

module "project" {
  source = "./modules/project"
  instance_type = var.instance_type
  artifact_bucket = var.artifact_bucket
  db_name = var.db_name
  db_user= var.db_user
}