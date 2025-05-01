module "codebuild_project" {
  source = "../../"

  name             = "my-codebuild-project"
  description      = "Builds on workflow events"
  build_timeout    = 10
  service_role_arn = "arn:aws:iam::123456789012:role/codebuild-role"
  // Running mode
  environment_type = "LINUX_CONTAINER"
  // Compute Type: EC2
  environment_compute_type = "BUILD_GENERAL1_SMALL"
  // Image: EC2 AMI Image
  environment_image = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
  // As the access level is repo; remote repo address
  source_location     = "https://github.com/${var.github_org_name}/my-repo"
  codeconnections_arn = "arn:aws:codestar-connections:us-east-1:123456789012:connection/abc123"
  github_org_name     = var.github_org_name
}
