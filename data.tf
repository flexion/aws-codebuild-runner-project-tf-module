data "aws_iam_role" "role" {
  name = var.service_role_name
}

data "aws_ssm_parameter" "github_personal_access_token" {
  count           = var.github_personal_access_token_ssm_parameter != null ? 1 : 0
  name            = var.github_personal_access_token_ssm_parameter
  with_decryption = true
}