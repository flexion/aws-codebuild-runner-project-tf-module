# TODO: Add support for private ecr images

#
resource "aws_codebuild_project" "this" {
  name          = var.name
  description   = var.description
  build_timeout = var.build_timeout
  service_role = (
    var.iam_role_name == null
    ? aws_iam_role.this[0].arn
    : "arn:aws:iam::${local.aws_account_id}:role/${var.iam_role_name}"
  )

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type         = var.environment_type
    compute_type = var.environment_compute_type
    image        = var.environment_image

    # privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name = (
        var.cloudwatch_logs_group_name == null
        ? aws_cloudwatch_log_group.codebuild[0].name
        : data.aws_cloudwatch_log_group.codebuild[0].name
      )
      stream_name = local.cloudwatch_logs_steam_name
    }
  }

  source {
    type            = var.runner_provider
    location        = var.runner_provider == "GITHUB" ? var.runner_location : "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  dynamic "vpc_config" {
    for_each = contains(split("_", var.environment_compute_type), "LAMBDA") ? toset([]) : toset([1])
    content {
      vpc_id             = var.vpc_id
      subnets            = var.subnet_ids
      security_group_ids = local.security_group_ids
    }
  }
}

resource "aws_codebuild_webhook" "this" {
  # depends_on   = [aws_codebuild_source_credential.string, aws_codebuild_source_credential.ssm]
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
  dynamic "scope_configuration" {
    for_each = var.runner_provider == "GITHUB" ? toset([1]) : toset([])
    content {
      domain = var.runner_domain
      name   = var.runner_location
      scope  = "GITHUB_ORGANIZATION"
    }
  }
}