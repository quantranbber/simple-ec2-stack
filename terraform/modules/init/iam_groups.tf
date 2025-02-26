resource "aws_iam_group" "develop" {
  name = "develop"
}

resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group" "devops" {
  name = "devops"
}

resource "aws_iam_group_policy_attachment" "admin_policy" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_group_policy_attachment" "develop_policy" {
  group      = aws_iam_group.develop.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


resource "aws_iam_group_policy_attachment" "devops_policy" {
  group      = aws_iam_group.devops.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}