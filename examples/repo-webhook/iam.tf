data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild-exec-role" {
  name               = "my-codebuild-project-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
