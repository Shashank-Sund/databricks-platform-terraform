output "group_id" {
  value = module.identity.group_id
}

output "created_user_ids" {
  description = "email -> id. After destroy, hard-delete with: databricks account users delete <id>"
  value       = module.identity.created_user_ids
}

output "demo_schema" {
  value = "${var.grant_catalog}.${databricks_schema.demo.name}"
}
