resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-backend-test-uniq5461313"

  tags = {
    Name        = "terraform_backend"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "terraform_backend_ownership" {
  bucket = aws_s3_bucket.terraform_backend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform_backend_acl" {
  bucket = aws_s3_bucket.terraform_backend.id
  acl    = "private"
}