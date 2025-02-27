# db
resource "aws_ssm_parameter" "db_host" {
  name  = "/myapp/db/DB_HOST"
  type  = "String"
  value = aws_db_instance.rds_postgres.address
}

resource "aws_ssm_parameter" "db_user" {
  name  = "/myapp/db/DB_USER"
  type  = "String"
  value = var.db_user
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/myapp/db/DB_PASSWORD"
  type  = "SecureString"
  value = random_password.db_password.result
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/myapp/db/DB_NAME"
  type  = "String"
  value = var.db_name
}

# ecr
resource "aws_ssm_parameter" "ecr_repo_url" {
  name  = "/myapp/ecr/url"
  type  = "String"
  value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.default_region}.amazonaws.com"
}

resource "aws_ssm_parameter" "ecr_image_name" {
  name  = "/myapp/ecr/image"
  type  = "String"
  value = "${var.ecr_repo_name}:latest"
}