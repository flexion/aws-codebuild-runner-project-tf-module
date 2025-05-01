module "codebuild_project" {
  source = "../.."

  name             = "my-codebuild-project"
  description      = "Builds on workflow events"
  build_timeout    = 10
  service_role_arn = aws_iam_role.codebuild-exec-role.arn
  // All environment variable defaults except Memory
  environment_compute_type = "BUILD_LAMBDA_4GB"
  // As the access level is org; source_location must be CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION (this is default as well)
  // source_location          = "https://github.com/my-org/my-repo"
  codeconnections_arn = aws_codeconnections_connection.private-code-connection.arn
  github_org_name     = var.github_org_name
}

resource "aws_codeconnections_connection" "private-code-connection" {
  name          = "my-codebuild-project-connection"
  provider_type = "GitHub"
}
