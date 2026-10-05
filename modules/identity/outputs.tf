output "group_id" {
  description = "Account SCIM id of the group. Feed this to the onboarding module (entitlements, workspace assignment)."
  value       = databricks_group.this.id
}

output "group_name" {
  description = "Group display name. Used as the principal for UC grants and policy ACLs."
  value       = databricks_group.this.display_name
}

output "member_ids" {
  description = "Map of email -> SCIM user id for every group member."
  value       = local.member_ids
}

output "created_user_ids" {
  description = <<-EOT
    Map of email -> id for users Terraform CREATED (empty when scim_managed_users=true).
    Note: destroy only DEACTIVATES account users. To fully remove them run:
      databricks account users delete <id>
  EOT
  value       = { for e, u in databricks_user.this : e => u.id }
}
