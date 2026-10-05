terraform {
  required_version = ">= 1.5.0"

  required_providers {
    databricks = {
      source = "databricks/databricks"
      # Tested against 1.135.0 (2026-09). Floor chosen so that
      # databricks_tag_policy and databricks_budget_policy both resolve.
      version = ">= 1.84.0"
    }
  }
}
