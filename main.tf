resource "aws_codebuild_project" "this" {
  name          = var.name
  description   = var.description
  build_timeout = var.build_timeout
  # service_role  = var.service_role_arn
  service_role = data.aws_iam_role.role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type                        = var.environment_type
    compute_type                = var.environment_compute_type
    image                       = var.environment_image
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    dynamic "cloudwatch_logs" {
      for_each = try(var.cloudwatch_logs_group_name, "") == "" ? toset([]) : toset([1])
      content {
        group_name  = var.cloudwatch_logs_group_name
        stream_name = var.cloudwatch_logs_stream_name == "" ? var.name : var.cloudwatch_logs_stream_name
      }
    }
  }

  source {
    type     = "GITHUB"
    location = var.source_location

    dynamic "auth" {
      for_each = var.codeconnections_arn != null ? [1] : []
      content {
        type     = "CODECONNECTIONS"
        resource = var.codeconnections_arn
      }
    }

    dynamic "auth" {
      for_each = var.github_personal_access_token_ssm_parameter != null && var.pat_override == true ? [1] : []
      content {
        type     = "SECRETS_MANAGER"
        resource = aws_secretsmanager_secret.this[0].arn
      }
    }
  }

}

resource "aws_codebuild_webhook" "this" {
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"


  dynamic "filter_group" {
    for_each = local.all_filter_groups
    content {
      dynamic "filter" {
        for_each = filter_group.value
        content {
          type    = filter.value.type
          pattern = filter.value.pattern

          # Handle optional exclude_matched_pattern
          # Use ternary to avoid setting null (Terraform doesn't like null bools in some providers)
          exclude_matched_pattern = contains(keys(filter.value), "exclude_matched_pattern") ? filter.value.exclude_matched_pattern : false
        }
      }
    }
  }


  dynamic "scope_configuration" {
    for_each = var.source_location == "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION" ? [1] : []
    content {
      scope = "GITHUB_ORGANIZATION"
      name  = var.github_org_name
    }
  }
}
