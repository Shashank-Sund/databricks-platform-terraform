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
