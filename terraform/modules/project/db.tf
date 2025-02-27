data "aws_rds_engine_version" "version" {
  engine             = "postgres"
  preferred_versions = ["16.3"]
}

resource "random_password" "db_password" {
  length           = 16
  special         = true
}

resource "aws_db_instance" "rds_postgres" {
  identifier            = "my-postgres-db"
  engine               = "postgres"
  engine_version       = data.aws_rds_engine_version.version.version
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  username            = var.db_user
  password            = random_password.db_password.result
  db_name             = var.db_name
  publicly_accessible  = true
  skip_final_snapshot  = true
  deletion_protection  = false

  multi_az             = false
  backup_retention_period = 0

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-free-tier-sg"
  description = "Allow PostgreSQL inbound traffic"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}