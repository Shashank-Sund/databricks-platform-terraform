# ---------------------------------------------------------------------------
# Provider template (reference)
#
# This repo talks to Databricks at TWO scopes:
#   * account   -> accounts.cloud.databricks.com (groups, users, workspace
#                  assignment, budget/usage policies)
#   * workspace -> a specific workspace URL (entitlements, UC grants,
#                  cluster policies, tag policies)
#
# Every module declares provider aliases (databricks.account /
# databricks.workspace) and the EXAMPLES wire real credentials into them.
# This root file is a copy-paste reference; the runnable configs live in
# examples/.
#
# AUTH, two supported paths (pick one per provider):
#   1. OAuth service principal (recommended for CI/prod):
#        set account_id + host, and export
#        DATABRICKS_CLIENT_ID / DATABRICKS_CLIENT_SECRET
#   2. Named CLI profile (handy for local dev):
#        set *_profile to a profile in ~/.databrickscfg
#
# Leaving an argument null makes the provider fall back to the profile/env.
# ---------------------------------------------------------------------------

provider "databricks" {
  alias      = "account"
  host       = var.account_host
  account_id = var.account_id
  profile    = var.account_profile
}

provider "databricks" {
  alias   = "workspace"
  host    = var.workspace_host
  profile = var.workspace_profile
}
