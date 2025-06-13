locals {
  secrets_manager_kvs = {
    ServerType = "GITHUB"
    AuthType = "PERSONAL_ACCESS_TOKEN"
    Token = data.aws_ssm_parameter.github_personal_access_token[0].value
  }
}

### Secrets manager secret for PAT
resource "aws_secretsmanager_secret" "this" {
  count = var.github_personal_access_token_ssm_parameter != null &&var.pat_override == true ? 1 : 0
  name = var.name
  tags = {
    "codebuild:source" = ""
    "codebuild:source:provider" = "github"
    "codebuild:source:type" = "personal_access_token"
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.github_personal_access_token_ssm_parameter != null && var.pat_override == true ? 1 : 0
  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode(local.secrets_manager_kvs)
}

### Option to specify default PAT. Only works if SSM Param is given and override isn't enabled.
resource "aws_codebuild_source_credential" "ssm" {
  count       = var.github_personal_access_token_ssm_parameter != null && var.pat_override == false ? 1 : 0
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = data.aws_ssm_parameter.github_personal_access_token[0].value
}

### Provide service role access to secrets manager secret
data "aws_iam_policy_document" "this" {
  statement {
    sid    = "EnableAnotherAWSAccountToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::123456789012:root",
        "arn:aws:iam::941681414890:role/${var.service_role_name}"
      ]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret_policy" "this" {
  secret_arn = aws_secretsmanager_secret.this.arn
  policy     = data.aws_iam_policy_document.this.json
}