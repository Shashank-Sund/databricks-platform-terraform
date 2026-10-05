output "workspace_assignment_id" {
  description = "Composite id of the workspace permission assignment (workspace_id|principal_id)."
  value       = databricks_mws_permission_assignment.this.id
}

output "entitlements_id" {
  value = databricks_entitlements.this.id
}

output "catalog_grant_ids" {
  value = { for k, g in databricks_grant.catalog : k => g.id }
}

output "schema_grant_ids" {
  value = { for k, g in databricks_grant.schema : k => g.id }
}
