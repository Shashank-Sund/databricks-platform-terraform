module "finops" {
  source = "../../modules/finops-tagging"
  providers = {
    databricks.account   = databricks.account
    databricks.workspace = databricks.workspace
  }

  cluster_policy_name   = var.cluster_policy_name
  required_tag_keys     = var.required_tag_keys
  allowlist_tags        = var.allowlist_tags
  use_legacy_single_tag = var.use_legacy_single_tag

  create_governed_tags  = var.create_governed_tags
  governed_tag_policies = var.governed_tag_policies

  create_budget_policy         = var.create_budget_policy
  budget_policy_name           = var.budget_policy_name
  budget_policy_tags           = var.budget_policy_tags
  budget_binding_workspace_ids = var.budget_binding_workspace_ids
}
