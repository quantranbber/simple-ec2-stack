data "aws_rds_engine_version" "version" {
  engine             = "postgres"
  preferred_versions = ["14.17"]
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "My RDS Subnet Group"
  subnet_ids = [
    aws_subnet.db_subnet1.id,
    aws_subnet.db_subnet2.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "rds_postgres" {
  identifier           = "my-postgres-db"
  engine               = "postgres"
  engine_version       = data.aws_rds_engine_version.version.version
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  username             = var.db_user
  password             = random_password.db_password.result
  db_name              = var.db_name
  publicly_accessible  = false
  skip_final_snapshot  = true
  deletion_protection  = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  multi_az                = false
  backup_retention_period = 0

  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

# disable ssl check
# resource "aws_db_parameter_group" "custom_pg15" {
#   name   = "custom-postgres15-ssl"
#   family = "postgres15"

#   parameter {
#     name  = "rds.force_ssl"
#     value = "0"
#   }
# }