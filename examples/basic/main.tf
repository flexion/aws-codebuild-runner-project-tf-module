module "github_runner" {
  source = "../../"

  name            = "github-runner-codebuild-example"
  source_location = "https://github.com/my-org/my-repo.git"


  description = "Created by my-org/my-runner-repo.git"

  # github_personal_access_token = "example"

  vpc_id     = "vpc-0ffaabbcc1234"
  subnet_ids = ["subnet-0123", "subnet-0456"]
}
