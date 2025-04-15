variable "name" {
  type        = string
  description = "Name of the CodeBuild project"
}

variable "description" {
  type        = string
  description = "Description of the CodeBuild project"
}

variable "build_timeout" {
  type        = number
  default     = 5
  description = "Build timeout in minutes"
}

variable "service_role_arn" {
  type        = string
  description = "IAM role ARN for CodeBuild to assume"
}

variable "environment_type" {
  type        = string
  default     = "LINUX_LAMBDA_CONTAINER"
}

variable "environment_compute_type" {
  type        = string
  default     = "BUILD_LAMBDA_2GB"
}

variable "environment_image" {
  type        = string
  default     = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
}

variable source_location {  
  type        = string
  description = "The git remote address for the repository"
  default     = "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
}

variable "codeconnections_arn" {
  type        = string
  description = "Preapproved ARN of the CodeConnection"
}

variable "additional_filter_groups" {
  description = "Additional filter groups to be appended to the default"
  type        = list(object({
    type    = string
    pattern = string
  }))
  default = []
}
