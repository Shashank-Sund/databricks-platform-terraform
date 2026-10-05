# A compute policy the whole cohort may use. Created here so we can demo the
# cohort module's cluster-policy-access wiring end to end.
resource "databricks_cluster_policy" "cohort" {
  provider = databricks.workspace
  name     = var.cluster_policy_name
  definition = jsonencode({
    autotermination_minutes = { type = "range", maxValue = 60, defaultValue = 20 }
  })
}

# Throwaway schema the example owns, to demo a cohort UC grant.
resource "databricks_schema" "demo" {
  provider      = databricks.workspace
  catalog_name  = var.grant_catalog
  name          = var.demo_schema_name
  comment       = "zz-tfdemo throwaway schema for cohort grant demo"
  force_destroy = true
}

# One call: group + all members + workspace assignment + entitlements +
# UC grant + cluster-policy access.
module "cohort" {
  source = "../../modules/cohort"
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }

  group_name         = var.group_name
  member_emails      = var.member_emails
  scim_managed_users = var.scim_managed_users

  workspace_id         = var.workspace_id
  allow_cluster_create = var.allow_cluster_create

  schema_grants = {
    "${var.grant_catalog}.${databricks_schema.demo.name}" = ["USE_SCHEMA", "SELECT"]
  }

  grant_cluster_policy_access = true
  cluster_policy_id           = databricks_cluster_policy.cohort.id
}
