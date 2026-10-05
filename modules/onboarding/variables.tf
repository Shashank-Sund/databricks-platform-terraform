variable "group_id" {
  type        = string
  description = "Account SCIM id of the group being onboarded (from the identity module)."
}

variable "group_name" {
  type        = string
  description = "Group display name, used as the principal for UC grants and the cluster-policy ACL."
}

variable "workspace_id" {
  type        = number
  description = "Numeric id of the EXISTING workspace to assign the group to (dev / prod / any)."
}

variable "workspace_permissions" {
  type        = list(string)
  description = "Workspace-assignment level for the group: [\"USER\"] or [\"ADMIN\"]."
  default     = ["USER"]
}

# --- Entitlements (inherited by every group member) ---
variable "allow_cluster_create" {
  type    = bool
  default = false
}

variable "allow_instance_pool_create" {
  type    = bool
  default = false
}

variable "databricks_sql_access" {
  type    = bool
  default = true
}

variable "workspace_access" {
  type    = bool
  default = true
}

# --- Unity Catalog grants (non-authoritative: only adds this group's grant) ---
variable "catalog_grants" {
  type        = map(list(string))
  description = "Map of catalog_name => list of privileges, e.g. { my_cat = [\"USE_CATALOG\"] }."
  default     = {}
}

variable "schema_grants" {
  type        = map(list(string))
  description = "Map of \"catalog.schema\" => list of privileges, e.g. { \"my_cat.my_schema\" = [\"USE_SCHEMA\",\"SELECT\"] }."
  default     = {}
}

# --- Cluster-policy access ---
variable "grant_cluster_policy_access" {
  type        = bool
  description = "Set true to grant the group access to cluster_policy_id. (A separate flag so it works even when the policy id is only known after apply.)"
  default     = false
}

variable "cluster_policy_id" {
  type        = string
  description = "Cluster policy to grant the group CAN_USE on (e.g. the FinOps policy). Used only when grant_cluster_policy_access = true."
  default     = null
}

variable "cluster_policy_permission" {
  type    = string
  default = "CAN_USE"
}
