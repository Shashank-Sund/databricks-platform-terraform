output "group_id" {
  value = module.cohort.group_id
}

output "member_ids" {
  value = module.cohort.member_ids
}

output "created_user_ids" {
  description = "email -> id. After destroy, hard-delete each with: databricks account users delete <id>"
  value       = module.cohort.created_user_ids
}

output "cluster_policy_id" {
  value = databricks_cluster_policy.cohort.id
}
