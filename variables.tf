variable "name" {
  type        = string
  description = "Name of the CodeBuild project"
}

variable "description" {
  type        = string
  description = "Description of the CodeBuild project"
  default     = ""
}

variable "build_timeout" {
  type        = number
  default     = 5
  description = "Build timeout in minutes"
}

variable "service_role_name" {
  type        = string
  description = "IAM role name for CodeBuild to assume"
}

variable "cloudwatch_logs_group_name" {
  type        = string
  description = "Name of the CloudWatch log group"
  default     = ""
}

variable "cloudwatch_logs_stream_name" {
  type        = string
  description = "Name of the CloudWatch log stream"
  default     = ""
}

variable "github_personal_access_token_ssm_parameter" {
  description = "The GitHub personal access token to use for accessing the repository. If not specified then GitHub auth must be configured separately."
  type        = string
  default     = null
}

variable "codeconnections_arn" {
  type        = string
  description = "preauthorized ARN of the CodeConnection"
  default     = null
}

variable "docker_server_compute_type" {
  description = "Compute type for the Docker server. Default: null. Valid values: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_XLARGE, and BUILD_GENERAL1_2XLARGE."
  type        = string
  default     = null
}

variable "docker_server_security_group_ids" {
  description = "The list of Security Group IDs for the Docker server."
  type        = list(string)
  default     = null
}

variable "environment_type" {
  type        = string
  description = "LINUX_CONTAINER for EC2 and LINUX_LAMBDA_CONTAINER for Lambda"
  default     = "LINUX_LAMBDA_CONTAINER"
}

variable "environment_compute_type" {
  type        = string
  description = "BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_LAMBDA_2GB, BUILD_LAMBDA_4GB, etc"
  default     = "BUILD_LAMBDA_2GB"
}

variable "environment_image" {
  type        = string
  description = "applicable image of ec2 or lambda"
  default     = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
}

variable "environment_image_pull_creds" {
  type        = string
  description = "Type of credentials AWS CodeBuild uses to pull images in your build. Valid values: CODEBUILD, SERVICE_ROLE."
  default     = "CODEBUILD"
}

variable "source_buildspec" {
  type        = string
  description = "The build spec declaration to use for this build project's related builds. Enter a path from your repository's root dir."
  default     = null
}

variable "source_git_submodules_config_fetch" {
  type        = bool
  description = "Whether to fetch Git submodules for the AWS CodeBuild build project."
  default     = false
}

variable "source_location" {
  type        = string
  description = "The git remote address for the repository"
  default     = "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
}

variable "github_org_name" {
  type        = string
  description = "Name of your github org if webhook is of org level"
}

variable "additional_filter_groups" {
  description = "Additional filter groups to be appended to the default"
  type = list(list(object({
    type                    = string
    pattern                 = string
    exclude_matched_pattern = optional(bool)
  })))
  default = []
}

variable "pat_override" {
  description = "Is the PAT provided an override of the default account token. Default: true"
  default     = true
  type        = bool
}

variable "privileged_mode" {
  description = "Is privileged mode enabled for AWS CodeBuild. Required for Docker builds. Default: false"
  type        = bool
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for AWS CodeBuild to launch ephemeral instances in."
  default     = null
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs for AWS CodeBuild to launch ephemeral EC2 instances in."
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "The list of Security Group IDs for AWS CodeBuild to launch ephemeral EC2 instances in."
  default     = []
}
