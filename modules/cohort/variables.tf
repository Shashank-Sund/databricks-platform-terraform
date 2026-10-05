# A cohort = one group + its members + full workspace onboarding, in one call.
# Used for hackathons/classes (many disposable users) and for teams.

variable "group_name" {
  type = string
}

variable "member_emails" {
  type    = list(string)
  default = []
}

variable "scim_managed_users" {
  type        = bool
  description = "See modules/identity. false = Terraform creates users; true = SCIM owns them, Terraform looks them up."
  default     = false
}

variable "workspace_id" {
  type = number
}

variable "workspace_permissions" {
  type    = list(string)
  default = ["USER"]
}

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

variable "catalog_grants" {
  type    = map(list(string))
  default = {}
}

variable "schema_grants" {
  type    = map(list(string))
  default = {}
}

variable "grant_cluster_policy_access" {
  type        = bool
  description = "Set true to grant the cohort access to cluster_policy_id."
  default     = false
}

variable "cluster_policy_id" {
  type        = string
  description = "Cluster policy (e.g. the FinOps policy) to grant the cohort CAN_USE on. Used only when grant_cluster_policy_access = true."
  default     = null
}
