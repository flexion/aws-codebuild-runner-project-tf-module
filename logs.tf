locals {
  cloudwatch_logs_group_arn = (
    var.cloudwatch_logs_group_name == null
    ? aws_cloudwatch_log_group.codebuild[0].arn
    : data.aws_cloudwatch_log_group.codebuild[0].arn
  )

  cloudwatch_logs_steam_name = (
    var.cloudwatch_logs_stream_name == null
    ? var.name
    : var.cloudwatch_logs_stream_name
  )
}

resource "aws_cloudwatch_log_group" "codebuild" {
  count             = var.cloudwatch_logs_group_name == null ? 1 : 0
  name              = "/aws/codebuild/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  # kms_key_id        = var.kms_key_id
  tags              = var.tags
}

data "aws_cloudwatch_log_group" "codebuild" {
  count = var.cloudwatch_logs_group_name == null ? 0 : 1
  name  = var.cloudwatch_logs_group_name
}
