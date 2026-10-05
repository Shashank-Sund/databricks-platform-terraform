output "cluster_policy_id" {
  description = "Grant this to a group via the onboarding module so they can launch governed classic compute."
  value       = module.finops.cluster_policy_id
}

output "cluster_policy_definition_json" {
  value = module.finops.cluster_policy_definition_json
}

output "governed_tag_policy_ids" {
  value = module.finops.governed_tag_policy_ids
}

output "budget_policy_id" {
  value = module.finops.budget_policy_id
}
