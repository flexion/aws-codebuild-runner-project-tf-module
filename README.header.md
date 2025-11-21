# Terraform AWS CodeBuild Runner Project

This Terraform module provisions an AWS CodeBuild Runner project with an attached webhook. Currently, AWS does not support creating Runner Projects via API or CLI. This module is a workaround. Terraform creates a default project and, by applying certain webhooks, it converts the project into a Runner project. This module is useful for teams that want to run GitHub Actions on AWS-managed on-demand compute.

---

## 🛠️ Prerequisites

- A GitHub App **"AWS Connector for GitHub"** successfully installed and configured in your AWS account. [More info on that](https://qnetconfluence.cms.gov/display/ISFCS/Configuring+Github+Runners+using+AWS+CodeBuild)
- CodeConnection itself can be provisioned via Terraform but requires manual authorization from AWS. The module will fail if the connection is not authorized.



## ✨ Features

- 🚀 Provisions a CodeBuild Runner project using GitHub as the source (via CodeConnections)
- 📦 Adds default filter groups to capture key events (indirectly creates a runner project without official support)
- ➕ Supports additional user-supplied filter groups
- 🧠 Automatically configures `scope_configuration` when applicable (i.e., webhook access at repo level vs org level)
- 🔁 Defaults to Lambda compute with 2 GB memory, Linux OS, and Node.js runtime

---

## 📦 Module Usage Examples

See the [examples](examples) dir for examples of usage: 

1. [Access level - Repo | Compute - EC2 | Mode - Container](examples/repo-ec2)
1. [Access level - Org | Compute - Lambda (4 GB) | Mode - Container](examples/org-lambda)
1. [Repo-level access with additional webhook filter](examples/repo-webhook)

---

## 🧩 Default Filter Groups

This default filter group is the core logic that triggers creation of a runner project. Since AWS does not officially support provisioning CodeBuild runner projects via API, this webhook indirectly transforms a default CodeBuild project into a runner-enabled project.

```tf
[ # group 1
  {
    type    = "EVENT"
    pattern = "WORKFLOW_JOB_QUEUED"
  }
]
```

---


## 🔧 Input Variables

