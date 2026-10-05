# 1. Assign the group to an existing workspace (account-level action).
resource "databricks_mws_permission_assignment" "this" {
  provider     = databricks.account
  workspace_id = var.workspace_id
  principal_id = var.group_id
  permissions  = var.workspace_permissions
}

# 2. Entitlements on the group (workspace-scoped). Every member inherits these.
#    Depends on the assignment so the workspace can resolve the group first.
resource "databricks_entitlements" "this" {
  provider                   = databricks.workspace
  group_id                   = var.group_id
  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
  databricks_sql_access      = var.databricks_sql_access
  workspace_access           = var.workspace_access

  depends_on = [databricks_mws_permission_assignment.this]
}

# 3. Unity Catalog grants (databricks_grant is per-principal / non-authoritative,
#    so it never revokes grants other people already hold on the securable).
resource "databricks_grant" "catalog" {
  provider   = databricks.workspace
  for_each   = var.catalog_grants
  catalog    = each.key
  principal  = var.group_name
  privileges = each.value
}

resource "databricks_grant" "schema" {
  provider   = databricks.workspace
  for_each   = var.schema_grants
  schema     = each.key
  principal  = var.group_name
  privileges = each.value
}

# 4. Cluster-policy access: let the group USE a governed compute policy.
resource "databricks_permissions" "cluster_policy" {
  provider          = databricks.workspace
  count             = var.grant_cluster_policy_access ? 1 : 0
  cluster_policy_id = var.cluster_policy_id

  access_control {
    group_name       = var.group_name
    permission_level = var.cluster_policy_permission
  }

  # Workspace ACLs resolve the group by name, which only works once the group
  # has propagated into the workspace. Chain after the assignment + entitlements
  # so the principal is resolvable.
  depends_on = [
    databricks_mws_permission_assignment.this,
    databricks_entitlements.this,
  ]
}
