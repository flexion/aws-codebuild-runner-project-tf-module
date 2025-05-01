locals {
  # create_security_group = local.has_vpc_config && length(var.security_group_ids) == 0
  security_group_name   = coalesce(var.security_group_name, var.name)

  security_group_ids = concat(
    contains(split("_", var.environment_compute_type), "LAMBDA")
    ? []
    : [aws_security_group.codebuild[0].id],
    var.security_group_ids
  )
}

resource "aws_security_group" "codebuild" {
  count       = contains(split("_", var.environment_compute_type), "LAMBDA") ? 0 : 1
  vpc_id      = var.vpc_id
  name        = local.security_group_name
  description = "Security group for CodeBuild project ${var.name}"
  tags = {
    Name = local.security_group_name
  }
}

resource "aws_vpc_security_group_egress_rule" "codebuild" {
  count             = contains(split("_", var.environment_compute_type), "LAMBDA") ? 0 : 1
  security_group_id = aws_security_group.codebuild[count.index].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow all traffic to ALL"
}

resource "aws_vpc_security_group_ingress_rule" "codebuild" {
  count             = contains(split("_", var.environment_compute_type), "LAMBDA") ? 0 : 1
  security_group_id = aws_security_group.codebuild[count.index].id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  description = "Allow HTTPS traffic from ALL"
}
