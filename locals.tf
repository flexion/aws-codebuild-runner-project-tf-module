
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
