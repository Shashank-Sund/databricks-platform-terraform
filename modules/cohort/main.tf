module "identity" {
  source = "../identity"
  providers = {
    databricks.account = databricks.account
  }

  group_name         = var.group_name
  member_emails      = var.member_emails
  scim_managed_users = var.scim_managed_users
}

module "onboarding" {
  source = "../onboarding"
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }

  group_id   = module.identity.group_id
  group_name = module.identity.group_name

  workspace_id          = var.workspace_id
  workspace_permissions = var.workspace_permissions

  allow_cluster_create       = var.allow_cluster_create
  allow_instance_pool_create = var.allow_instance_pool_create
  databricks_sql_access      = var.databricks_sql_access
  workspace_access           = var.workspace_access

  catalog_grants = var.catalog_grants
  schema_grants  = var.schema_grants

  grant_cluster_policy_access = var.grant_cluster_policy_access
  cluster_policy_id           = var.cluster_policy_id
}
