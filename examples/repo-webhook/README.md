### Example: Repo-level access with additional webhook filter

```tf
module "codebuild_project" {
  source = "git@github.com:flexion/aws-codebuild-runner-project-tf-module.git?ref=1.0.0"

  name                     = "my-codebuild-project"
  description              = "Builds on workflow events"
  build_timeout            = 10
  service_role_arn         = aws_iam_role.codebuild-exec-role.arn
  // All environment variable defaults
  // As the access level is not org; source_location must be a repo name
  source_location          = "https://github.com/my-org/my-repo"
  codeconnections_arn      = aws_codeconnections_connection.private-code-connection.arn

   additional_filter_groups = [
    [  
      {  
        type    = "EVENT"
        pattern = "PUSH"
      },
      {  
        type    = "REPOSITORY_NAME"
        pattern = "test-*"
        exclude_matched_pattern = true
      }
    ]
  ]
}
```
