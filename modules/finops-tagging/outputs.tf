output "cluster_policy_id" {
  description = "Id of the classic-compute cluster policy. Pass to the onboarding module so a group can USE it."
  value       = var.create_cluster_policy ? databricks_cluster_policy.this[0].id : null
}

output "cluster_policy_definition_json" {
  description = "The generated enforcement JSON (handy for review / audit)."
  value       = jsonencode(local.cluster_policy_definition)
}

output "governed_tag_policy_ids" {
  value = { for k, tp in databricks_tag_policy.governed : k => tp.id }
}

output "budget_policy_id" {
  description = "Id of the serverless usage/budget policy."
  value       = var.create_budget_policy ? databricks_budget_policy.this[0].policy_id : null
}
