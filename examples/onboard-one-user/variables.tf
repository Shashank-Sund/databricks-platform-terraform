# --- connection ---
variable "account_id" {
  type    = string
  default = null
}
variable "account_host" {
  type    = string
  default = "https://accounts.cloud.databricks.com"
}
variable "account_profile" {
  type    = string
  default = null
}
variable "workspace_host" {
  type    = string
  default = null
}
variable "workspace_profile" {
  type    = string
  default = null
}

# --- scenario ---
variable "group_name" {
  type    = string
  default = "zz-tfdemo-onboard-one"
}

variable "member_emails" {
  type    = list(string)
  default = ["zz-tfdemo-test-1@example.com"]
}

variable "scim_managed_users" {
  type    = bool
  default = false
}

variable "workspace_id" {
  type        = number
  description = "Existing workspace to assign the user's group to."
}

variable "allow_cluster_create" {
  type    = bool
  default = false
}

# --- UC grant demo ---
# NOTE: On metastores that use Default Storage, only the UI can create new
# *catalogs*. So this example creates a throwaway *schema* inside an existing
# catalog you own and grants on it. On a metastore with a storage root you can
# instead create a throwaway catalog (databricks_catalog with storage_root).
variable "grant_catalog" {
  type        = string
  description = "An existing catalog you own/manage, in which this example creates a throwaway demo schema."
}

variable "demo_schema_name" {
  type    = string
  default = "zz_tfdemo_onboarding_demo"
}

variable "grant_catalog_usage" {
  type        = bool
  description = "Also add a (non-authoritative) USE_CATALOG grant for the group on grant_catalog."
  default     = true
}
