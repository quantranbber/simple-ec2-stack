variable "default_region" {
  type        = string
  description = "default region"
  default     = "ap-southeast-1"
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
  default     = "t2.micro"
}

variable "artifact_bucket" {
  type        = string
  description = "source codes artifact bucket"
  default     = "terraform-test-bucket-7634341"
}

variable "db_name" {
  type        = string
  description = "database name"
  default     = "myprj"
}

variable "db_user" {
  type        = string
  description = "db user"
  default     = "myprj"
}