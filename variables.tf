# ---------------------------------------------
# Project Variables
# ---------------------------------------------
variable "name" {
  type        = string
  description = "Name applied to all created resources"
  validation {
    condition     = length(var.name) > 0
    error_message = "The name must not be empty."
  }
}

variable "description" {
  type        = string
  description = "Description of the CodeBuild project"
  default     = ""
}

# ---------------------------------------------
# Runner Variables
# ---------------------------------------------

variable "runner_provider" {
  type        = string
  description = "The git provider, either GITHUB or GITHUB_ENTERPRISE"
  validation {
    condition     = contains(["GITHUB", "GITHUB_ENTERPRISE"], var.runner_provider)
    error_message = "The runner provider must be either GITHUB or GITHUB_ENTERPRISE."
  }
  default = "GITHUB"
}

variable "runner_location" {
  type        = string
  description = "Three options, Repository, Organization, or Enterprise"

}
# If runner location is Repository, provide the repository name, if Organization, provide the organization name, if Enterprise, provide the enterprise name
variable "runner_domain" {
  type        = string
  description = "The git remote address for the repository"
  default = ""
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

variable "codeconnections_arn" {
  type        = string
  description = "preauthorized ARN of the CodeConnection"
}

variable "environment_type" {
  type        = string
  description = "LINUX_CONTAINER for EC2 and LINUX_LAMBDA_CONTAINER for Lambda"
  default     = "LINUX_LAMBDA_CONTAINER"
}

variable "environment_compute_type" {
  type          = string
  description   = "BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_LAMBDA_2GB, BUILD_LAMBDA_4GB, etc" 
  default       = "BUILD_LAMBDA_2GB"
}

variable "environment_image" {
  type        = string
  description = "applicable image of ec2 or lambda"
  default     = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
}

variable source_location {  
  type        = string
  description = "The git remote address for the repository"
  default     = "CODEBUILD_DEFAULT_WEBHOOK_SOURCE_LOCATION"
}

variable github_org_name {
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

locals {
  default_filter_groups = [
    [ # group 1
      {
        type    = "EVENT"
        pattern = "WORKFLOW_JOB_QUEUED"
      }
    ]
  ]

  all_filter_groups = concat(local.default_filter_groups, var.additional_filter_groups)
}


# -----------------------------------------------------
# Optional variables
# -----------------------------------------------------



variable "cloudwatch_logs_group_name" {
  description = "Name of the log group used by the CodeBuild project. If not specified then a default is used."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 14
}


# vpc
variable "vpc_id" {
  type        = string
  description = "The VPC ID for AWS CodeBuild to launch ephemeral instances in."
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "The list of Subnet IDs for AWS CodeBuild to launch ephemeral EC2 instances in."
  default     = []
}

variable "security_group_name" {
  description = "Name to use on created Security Group. Defaults to `name`"
  type        = string
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of Security Group IDs for AWS CodeBuild to launch ephemeral EC2 instances in."
  default     = []
}

# IAM
variable "iam_role_name" {
  description = "Name of the IAM role to be used. If not specified then a role will be created"
  type        = string
  default     = null
}

variable "iam_role_assume_role_policy" {
  description = "The IAM role assume role policy document to use. If not specified then a default is used."
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Map of IAM role policy ARNs to attach to the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM service role"
  type        = string
  default     = null
}

# GitHub
variable "github_personal_access_token" {
  description = "The GitHub personal access token to use for accessing the repository. If not specified then GitHub auth must be configured separately."
  type        = string
  default     = null
}

variable "github_personal_access_token_ssm_parameter" {
  description = "The GitHub personal access token to use for accessing the repository. If not specified then GitHub auth must be configured separately."
  type        = string
  default     = null
}

# Encryption
# variable "kms_key_id" {
#   description = "The AWS KMS key to be used"
#   type        = string
#   default     = null
# }

# Custom image
variable "create_ecr_repository" {
  description = "If set to true then an ECR repository will be created, and an image needs to be pushed to it before running the build project"
  type        = string
  default     = false
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository to create or use. If not specified and `create_ecr_repository` is true, then a default is used."
  type        = string
  default     = null
}
