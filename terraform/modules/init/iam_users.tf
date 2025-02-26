resource "aws_iam_user" "developer1" {
  name = "developer1"
}

resource "aws_iam_user" "devops1" {
  name = "devops1"
}

resource "aws_iam_user" "admin1" {
  name = "admin1"
}

resource "aws_iam_group_membership" "develop_group" {
  name  = "develop-membership"
  group = aws_iam_group.develop.name
  users = [aws_iam_user.developer1.name]
}

resource "aws_iam_group_membership" "admin_group" {
  name  = "admin-membership"
  group = aws_iam_group.admin.name
  users = [aws_iam_user.admin1.name]
}

resource "aws_iam_group_membership" "devops_group" {
  name  = "devops-membership"
  group = aws_iam_group.devops.name
  users = [aws_iam_user.devops1.name]
}

resource "aws_iam_user_login_profile" "developer1" {
  user                    = aws_iam_user.developer1.name
  password_reset_required = true
}

resource "aws_iam_user_login_profile" "devops1" {
  user                    = aws_iam_user.devops1.name
  password_reset_required = true
}

resource "aws_iam_user_login_profile" "admin1" {
  user                    = aws_iam_user.admin1.name
  password_reset_required = true
}