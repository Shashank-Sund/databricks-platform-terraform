# A throwaway schema this example creates & owns inside an existing catalog, so
# the UC-grant path is apply-testable without disturbing any shared securable.
# force_destroy lets `terraform destroy` clean it up.
resource "databricks_schema" "demo" {
  provider      = databricks.workspace
  catalog_name  = var.grant_catalog
  name          = var.demo_schema_name
  comment       = "zz-tfdemo throwaway schema for onboarding grant demo"
  force_destroy = true
}

module "identity" {
  source = "../../modules/identity"
  providers = {
    databricks.account = databricks.account
  }

  group_name         = var.group_name
  member_emails      = var.member_emails
  scim_managed_users = var.scim_managed_users
}

module "onboarding" {
  source = "../../modules/onboarding"
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }

  group_id   = module.identity.group_id
  group_name = module.identity.group_name

  workspace_id         = var.workspace_id
  allow_cluster_create = var.allow_cluster_create

  # Optional catalog-level grant (non-authoritative; only adds this group).
  catalog_grants = var.grant_catalog_usage ? { (var.grant_catalog) = ["USE_CATALOG"] } : {}

  # Schema-level grant on the schema we just created (key references the
  # resource so Terraform creates the schema first).
  schema_grants = {
    "${var.grant_catalog}.${databricks_schema.demo.name}" = ["USE_SCHEMA", "SELECT"]
  }
}
