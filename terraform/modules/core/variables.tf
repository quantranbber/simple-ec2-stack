variable "default_region" {}
variable "environment" {}
variable "db_name" {}
variable "db_user" {}
variable "ecr_repo_name" {}
variable "project_image_scan_on_push" {
  type    = string
  default = "true"
}
variable "project_image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}