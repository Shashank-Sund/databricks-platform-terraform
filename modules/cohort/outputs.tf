output "group_id" {
  value = module.identity.group_id
}

output "group_name" {
  value = module.identity.group_name
}

output "member_ids" {
  value = module.identity.member_ids
}

output "created_user_ids" {
  description = "email -> id for Terraform-created users (empty when SCIM-managed). Use for post-destroy hard-delete."
  value       = module.identity.created_user_ids
}

output "workspace_assignment_id" {
  value = module.onboarding.workspace_assignment_id
}
