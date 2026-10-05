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

# --- cohort / hackathon ---
variable "group_name" {
  type    = string
  default = "zz-tfdemo-hackathon"
}

variable "member_emails" {
  type        = list(string)
  description = "The cohort. Add/remove emails and re-apply to onboard/offboard."
  default = [
    "zz-tfdemo-test-1@example.com",
    "zz-tfdemo-test-2@example.com",
  ]
}

variable "scim_managed_users" {
  type    = bool
  default = false
}

variable "workspace_id" {
  type = number
}

variable "allow_cluster_create" {
  type    = bool
  default = false
}

variable "cluster_policy_name" {
  type    = string
  default = "zz-tfdemo-hackathon-policy"
}

variable "grant_catalog" {
  type        = string
  description = "Existing catalog you own; a throwaway demo schema is created in it and granted to the cohort."
}

variable "demo_schema_name" {
  type    = string
  default = "zz_tfdemo_hackathon_demo"
}
