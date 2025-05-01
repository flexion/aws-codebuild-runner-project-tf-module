module "github_runner" {
  source = "../../"

  name            = "github-runner-codebuild-example"
  runner_location = "https://github.com/my-org/my-repo.git"


  description = "Created by my-org/my-runner-repo.git"

  codeconnections_arn = "arn:aws:codeconnections:us-east-1:941681414890:connection/f3c1c9c1-6e0b-44f3-ba9b-1e6cbc197dfd"
  
  # github_personal_access_token = "example"

  # vpc_id     = "vpc-0ffaabbcc1234"
  # subnet_ids = ["subnet-0123", "subnet-0456"]
}
