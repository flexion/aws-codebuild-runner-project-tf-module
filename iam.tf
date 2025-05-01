################################################################################
# Cloudwatch permissions
################################################################################
data "aws_iam_policy_document" "cloudwatch_required" {
  statement {
    sid    = "AllowCreateLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [local.cloudwatch_logs_group_arn]
  }

  statement {
    sid    = "AllowPutLogEvents"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${local.cloudwatch_logs_group_arn}:log-stream:${local.cloudwatch_logs_steam_name}/*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_required" {
  name   = "${var.name}-cloudwatch-logs"
  role   = var.iam_role_name == null ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.cloudwatch_required.json
}

################################################################################
# VPC permissions
################################################################################
data "aws_iam_policy_document" "networking_required" {
  # count = local.has_vpc_config ? 1 : 0
  statement {
    sid    = "AllowNetworkingDescribe"
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowNetworkingAttachDetach"
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${local.aws_region}:${local.aws_account_id}:network-interface/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = local.subnet_arns
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "networking_required" {
  count  = contains(split("_", var.environment_compute_type), "LAMBDA")? 0 : 1
  name   = "${var.name}-networking"
  role   = var.iam_role_name == null ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.networking_required.json
}

################################################################################
# CodeConnections permissions
################################################################################
data "aws_iam_policy_document" "codeconnections_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
      "codeconnections:UseConnection"
    ]
    //resources = ["arn:aws:codeconnections:us-east-1:941681414890:connection/f3c1c9c1-6e0b-44f3-ba9b-1e6cbc197dfd"]
    resources = [var.codeconnections_arn]
  }
}

resource "aws_iam_role_policy" "codeconnections_permissions" {
  count  = var.codeconnections_arn != "" ? 1 : 0
  name   = "${var.name}-codeconnections"
  role   = var.iam_role_name == null ? aws_iam_role.this[0].name : var.iam_role_name
  policy = data.aws_iam_policy_document.codeconnections_permissions.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

locals {
  assume_role_policy = var.iam_role_assume_role_policy == null ? data.aws_iam_policy_document.assume_role.json : var.iam_role_assume_role_policy
}

################################################################################
# Create role
################################################################################
resource "aws_iam_role" "this" {
  count                = var.iam_role_name == null ? 1 : 0
  name                 = var.name
  assume_role_policy   = local.assume_role_policy
  permissions_boundary = var.iam_role_permissions_boundary == null ? null : var.iam_role_permissions_boundary
}

################################################################################
# Custom permissions
################################################################################
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.iam_role_policies

  role       = var.iam_role_name == null ? aws_iam_role.this[0].name : var.iam_role_name
  policy_arn = each.value
}
