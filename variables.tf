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

# variable "service_role_arn" {
#   type        = string
#   description = "IAM role ARN for CodeBuild to assume"
# }

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
