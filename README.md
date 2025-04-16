# Terraform AWS CodeBuild Project with Webhook

This Terraform module provisions an AWS CodeBuild Runner project with an attached webhook. Currently, AWS does not support creating Runner Projects via API or CLI. This module is a workaround. Terraform creates a default project and, by applying certain webhooks, it converts the project into a Runner project. This module is useful for teams that want to run GitHub Actions on AWS-managed on-demand compute.

---

## 🛠️ Prerequisites

- A GitHub App **"AWS Connector for GitHub"** successfully installed and configured in your AWS account. [More info on that](https://qnetconfluence.cms.gov/display/ISFCS/Github+Runners+on+CodeBuild)
- CodeConnection itself can be provisioned via Terraform but requires manual authorization from AWS. The module will fail if the connection is not authorized.



## ✨ Features

- 🚀 Provisions a CodeBuild Runner project using GitHub as the source (via CodeConnections)
- 📦 Adds default filter groups to capture key events (indirectly creates a runner project without official support)
- ➕ Supports additional user-supplied filter groups
- 🧠 Automatically configures `scope_configuration` when applicable (i.e., webhook access at repo level vs org level)
- 🔁 Defaults to Lambda compute with 2 GB memory, Linux OS, and Node.js runtime

---

## 📦 Module Usage Examples

### Example 1: Access level - Repo | Compute - EC2 | Mode - Container

```tf
module "codebuild_project" {
  source = "git@github.com:flexion/aws-codebuild-runner-project-tf-module.git?ref=1.0.0"

  name                     = "my-codebuild-project"
  description              = "Builds on workflow events"
  build_timeout            = 10
  service_role_arn         = "arn:aws:iam::123456789012:role/codebuild-role"
  // Running mode
  environment_type         = "LINUX_CONTAINER"
  // Compute Type: EC2
  environment_compute_type = "BUILD_GENERAL1_SMALL"
  // Image: EC2 AMI Image
  environment_image        = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
  // As the access level is repo; remote repo address
  source_location          = "https://github.com/my-org/my-repo"
  codeconnections_arn      = "arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123"
  // github_org_name          = "my-org"  Only needed if the webhook access level is org level; will be ignored if source_location != "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
}
```

### Example 2: Access level - Org | Compute - Lambda (4 GB) | Mode - Container

```tf
module "codebuild_project" {
  source = "git@github.com:flexion/aws-codebuild-runner-project-tf-module.git?ref=1.0.0"

  name                     = "my-codebuild-project"
  description              = "Builds on workflow events"
  build_timeout            = 10
  service_role_arn         = aws_iam_role.codebuild-exec-role.arn
  // All environment variable defaults except Memory
  environment_compute_type = "BUILD_LAMBDA_4GB"
  // As the access level is org; source_location must be CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION (this is default as well)
  // source_location          = "https://github.com/my-org/my-repo"
  codeconnections_arn      = aws_codeconnections_connection.private-code-connection.arn
  github_org_name          = "my-org"
}
```

### Example 3: Repo-level access with additional webhook filter

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

---

## 🧩 Default Filter Groups

This default filter group is the core logic that triggers creation of a runner project. Since AWS does not officially support provisioning CodeBuild runner projects via API, this webhook indirectly transforms a default CodeBuild project into a runner-enabled project.

```tf
[ # group 1
  {
    type    = "EVENT"
    pattern = "WORKFLOW_JOB_QUEUED"
  }
]
```

---


## 🔧 Input Variables

| Name                     | Type   | Description                                                                 | Default                                         | Required |
|--------------------------|--------|-----------------------------------------------------------------------------|-------------------------------------------------|----------|
| `name`                   | string | Name of the CodeBuild project                                               | n/a                                             | ✅        |
| `description`            | string | Description of the project                                                  | `""`                                            | ❌        |
| `build_timeout`          | number | Build timeout in minutes                                                    | `5`                                             | ❌        |
| `service_role_arn`       | string | ARN of the IAM role for CodeBuild                                           | n/a                                             | ✅        |
| `codeconnections_arn`    | string | ARN of the CodeConnections resource for GitHub App                          | n/a                                             | ✅        |
| `environment_type`       | string | Type of build environment (e.g., `LINUX_CONTAINER`)                         | `"LINUX_CONTAINER"`                            | ❌        |
| `environment_compute_type` | string | Compute type (e.g., `BUILD_GENERAL1_SMALL`, `BUILD_LAMBDA_4GB`)             | `"BUILD_GENERAL1_SMALL"`                       | ❌        |
| `environment_image`      | string | Docker image for the build environment                                      | `"aws/codebuild/standard:6.0"`                 | ❌        |
| `source_location`        | string | GitHub repository HTTPS/SSH or CodeConnection location                      | `"CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"`  | ❌        |
| `github_org_name`        | string | GitHub organization name (only used when source_location is default)        | `"ccsq-isfcs"`                                 | ❌        |
| `additional_filter_groups` | list | List of additional filter groups (must include at least one `EVENT` filter) | `[]`                                            | ❌        |

> ℹ️ Notes:
> - A default filter group is always added to transform the project into a runner project.
> - `additional_filter_groups` are appended after the default filter group.
> - Each additional group must contain a filter with `type = "EVENT"`.
> - `exclude_matched_pattern` is optional and defaults to `false`.
> - `scope_configuration` is applied only when `source_location` is default or unset.

--- 

## ✅ Tested With

- Terraform v1.5+
- AWS Provider v5.x
- GitHub + CodeConnections integration
- Default and additional filter group handling