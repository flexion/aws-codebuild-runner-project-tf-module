## ℹ️  Notes:
> - A default filter group is always added to transform the project into a runner project.
> - `additional_filter_groups` are appended after the default filter group.
> - Each additional group must contain a filter with `type = "EVENT"`.
> - `exclude_matched_pattern` is optional and defaults to `false`.
> - `scope_configuration` is applied only when `source_location` is default or unset.

--- 

## ✅ Tested With

- Terraform v1.5+
- AWS Provider v5.x
- GitHub + CodeConnections integration
- Default and additional filter group handling
