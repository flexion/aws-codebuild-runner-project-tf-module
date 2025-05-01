locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region = data.aws_region.current.name

  subnet_arns = [for subnet_id in local.subnet_ids : "arn:aws:ec2:${local.aws_region}:${local.aws_account_id}:subnet/${subnet_id}"]

  subnet_ids = ["subnet-098d9c2f3bc83fd7e", "subnet-0a344602a03785971"]

}
