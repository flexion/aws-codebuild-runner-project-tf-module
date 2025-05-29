module "codebuild_project" {
  source = "../.."

  name              = "my-codebuild-project"
  description       = "Builds on workflow events"
  build_timeout     = 10
  service_role_name = aws_iam_role.codebuild-exec-role.name
  // All environment variable defaults
  // As the access level is not org; source_location must be a repo name
  source_location     = "https://github.com/${var.github_org_name}/my-repo"
  codeconnections_arn = aws_codeconnections_connection.private-code-connection.arn
  github_org_name     = var.github_org_name

  additional_filter_groups = [
    [
      {
        type    = "EVENT"
        pattern = "PUSH"
      },
      {
        type                    = "REPOSITORY_NAME"
        pattern                 = "test-*"
        exclude_matched_pattern = true
      }
    ]
  ]
}

resource "aws_codeconnections_connection" "private-code-connection" {
  name          = "my-codebuild-project-connection"
  provider_type = "GitHub"
}
