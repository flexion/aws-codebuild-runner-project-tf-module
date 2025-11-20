# Terraform AWS CodeBuild Runner Project

This Terraform module provisions an AWS CodeBuild Runner project with an attached webhook. Currently, AWS does not support creating Runner Projects via API or CLI. This module is a workaround. Terraform creates a default project and, by applying certain webhooks, it converts the project into a Runner project. This module is useful for teams that want to run GitHub Actions on AWS-managed on-demand compute.

---

## 🛠️ Prerequisites

- A GitHub App **"AWS Connector for GitHub"** successfully installed and configured in your AWS account. [More info on that](https://qnetconfluence.cms.gov/display/ISFCS/Configuring+Github+Runners+using+AWS+CodeBuild)
- CodeConnection itself can be provisioned via Terraform but requires manual authorization from AWS. The module will fail if the connection is not authorized.

## ✨ Features

- 🚀 Provisions a CodeBuild Runner project using GitHub as the source (via CodeConnections)
- 📦 Adds default filter groups to capture key events (indirectly creates a runner project without official support)
- ➕ Supports additional user-supplied filter groups
- 🧠 Automatically configures `scope_configuration` when applicable (i.e., webhook access at repo level vs org level)
- 🔁 Defaults to Lambda compute with 2 GB memory, Linux OS, and Node.js runtime

---

## 📦 Module Usage Examples

See the [examples](examples) dir for examples of usage:

1. [Access level - Repo | Compute - EC2 | Mode - Container](examples/repo-ec2)
1. [Access level - Org | Compute - Lambda (4 GB) | Mode - Container](examples/org-lambda)
1. [Repo-level access with additional webhook filter](examples/repo-webhook)

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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.95.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_source_credential.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_source_credential) | resource |
| [aws_codebuild_webhook.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_policy) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_ssm_parameter.github_personal_access_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_filter_groups"></a> [additional\_filter\_groups](#input\_additional\_filter\_groups) | Additional filter groups to be appended to the default | <pre>list(list(object({<br/>    type                    = string<br/>    pattern                 = string<br/>    exclude_matched_pattern = optional(bool)<br/>  })))</pre> | `[]` | no |
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Build timeout in minutes | `number` | `5` | no |
| <a name="input_cloudwatch_logs_group_name"></a> [cloudwatch\_logs\_group\_name](#input\_cloudwatch\_logs\_group\_name) | Name of the CloudWatch log group | `string` | `""` | no |
| <a name="input_cloudwatch_logs_stream_name"></a> [cloudwatch\_logs\_stream\_name](#input\_cloudwatch\_logs\_stream\_name) | Name of the CloudWatch log stream | `string` | `""` | no |
| <a name="input_codeconnections_arn"></a> [codeconnections\_arn](#input\_codeconnections\_arn) | preauthorized ARN of the CodeConnection | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the CodeBuild project | `string` | `""` | no |
| <a name="input_docker_server_compute_type"></a> [docker\_server\_compute\_type](#input\_docker\_server\_compute\_type) | Compute type for the Docker server. Default: null. Valid values: BUILD\_GENERAL1\_SMALL, BUILD\_GENERAL1\_MEDIUM, BUILD\_GENERAL1\_LARGE, BUILD\_GENERAL1\_XLARGE, and BUILD\_GENERAL1\_2XLARGE. | `string` | `null` | no |
| <a name="input_docker_server_security_group_ids"></a> [docker\_server\_security\_group\_ids](#input\_docker\_server\_security\_group\_ids) | The list of Security Group IDs for the Docker server. | `list(string)` | `null` | no |
| <a name="input_environment_compute_type"></a> [environment\_compute\_type](#input\_environment\_compute\_type) | BUILD\_GENERAL1\_SMALL, BUILD\_GENERAL1\_MEDIUM, BUILD\_LAMBDA\_2GB, BUILD\_LAMBDA\_4GB, etc | `string` | `"BUILD_LAMBDA_2GB"` | no |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | applicable image of ec2 or lambda | `string` | `"aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"` | no |
| <a name="input_environment_image_pull_creds"></a> [environment\_image\_pull\_creds](#input\_environment\_image\_pull\_creds) | Type of credentials AWS CodeBuild uses to pull images in your build. Valid values: CODEBUILD, SERVICE\_ROLE. | `string` | `"CODEBUILD"` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | LINUX\_CONTAINER for EC2 and LINUX\_LAMBDA\_CONTAINER for Lambda | `string` | `"LINUX_LAMBDA_CONTAINER"` | no |
| <a name="input_github_org_name"></a> [github\_org\_name](#input\_github\_org\_name) | Name of your github org if webhook is of org level | `string` | n/a | yes |
| <a name="input_github_personal_access_token_ssm_parameter"></a> [github\_personal\_access\_token\_ssm\_parameter](#input\_github\_personal\_access\_token\_ssm\_parameter) | The GitHub personal access token to use for accessing the repository. If not specified then GitHub auth must be configured separately. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the CodeBuild project | `string` | n/a | yes |
| <a name="input_pat_override"></a> [pat\_override](#input\_pat\_override) | Is the PAT provided an override of the default account token. Default: true | `bool` | `true` | no |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | Is privileged mode enabled for AWS CodeBuild. Required for Docker builds. Default: false | `bool` | `false` | no |
| <a name="input_service_role_name"></a> [service\_role\_name](#input\_service\_role\_name) | IAM role name for CodeBuild to assume | `string` | n/a | yes |
| <a name="input_source_buildspec"></a> [source\_buildspec](#input\_source\_buildspec) | The build spec declaration to use for this build project's related builds. Enter a path from your repository's root dir. | `string` | `null` | no |
| <a name="input_source_git_submodules_config_fetch"></a> [source\_git\_submodules\_config\_fetch](#input\_source\_git\_submodules\_config\_fetch) | Whether to fetch Git submodules for the AWS CodeBuild build project. | `bool` | `false` | no |
| <a name="input_source_location"></a> [source\_location](#input\_source\_location) | The git remote address for the repository | `string` | `"CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID for AWS CodeBuild to launch ephemeral instances in. | `string` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | The list of Security Group IDs for AWS CodeBuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | The list of Subnet IDs for AWS CodeBuild to launch ephemeral EC2 instances in. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_arn"></a> [project\_arn](#output\_project\_arn) | n/a |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | n/a |

## ℹ️  Notes:
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
