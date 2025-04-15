resource "aws_codebuild_project" "this" {
  name          = var.name
  description   = var.description
  build_timeout = var.build_timeout
  service_role  = var.service_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type                        = var.environment_type
    compute_type                = var.environment_compute_type
    image                       = var.environment_image
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type     = "GITHUB"
    location = var.source_location
    auth {
      type     = "CODECONNECTIONS"
      resource = var.codeconnections_arn
    }
  }

}

resource "aws_codebuild_webhook" "this" {
  project_name = aws_codebuild_project.this.name
  build_type   = "BUILD"
  filter_group {
    filter {  
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
  scope_configuration {
    scope  = "GITHUB_ORGANIZATION"
    name   = "ccsq-isfcs"
  }
}
