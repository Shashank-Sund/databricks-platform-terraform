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

# --- FinOps knobs (all pass through to the finops-tagging module) ---
# Defaults here are a sample taxonomy. Override via tfvars.
variable "cluster_policy_name" {
  type    = string
  default = "finops-governed"
}

variable "required_tag_keys" {
  type    = list(string)
  default = ["cost_center", "project"]
}

variable "allowlist_tags" {
  type = map(list(string))
  default = {
    department = ["ENGINEERING", "FINANCE", "MARKETING", "IT_OPS", "SHARED"]
  }
}

variable "use_legacy_single_tag" {
  type    = bool
  default = false
}

variable "create_governed_tags" {
  type    = bool
  default = true
}

variable "governed_tag_policies" {
  type = list(object({
    tag_key     = string
    description = optional(string)
    values      = optional(list(string), [])
  }))
  default = [
    {
      tag_key     = "department"
      description = "Example department (governed UC tag)."
      values      = ["ENGINEERING", "FINANCE", "MARKETING", "IT_OPS", "SHARED"]
    }
  ]
}

variable "create_budget_policy" {
  type    = bool
  default = true
}

variable "budget_policy_name" {
  type    = string
  default = "finops-serverless"
}

variable "budget_policy_tags" {
  type = map(string)
  default = {
    cost_center = "unassigned"
    project     = "unassigned"
    department  = "SHARED"
  }
}

variable "budget_binding_workspace_ids" {
  type    = list(number)
  default = []
}
