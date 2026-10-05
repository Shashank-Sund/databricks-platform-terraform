# ===========================================================================
# FinOps tagging + enforcement
#
# Cost tags only reach the bill on COMPUTE, so this module enforces them on the
# two compute paths:
#   * CLASSIC compute   -> databricks_cluster_policy REQUIRES the tags.
#   * SERVERLESS compute -> databricks_budget_policy CARRIES the tags onto
#                           serverless usage (the serverless "usage policy").
# Governed UC tags (databricks_tag_policy) are a COMPANION for data-asset
# governance, not the billing path.
#
# All defaults below are a sample cost-tag taxonomy and are fully
# editable via variables -- you should not need to touch the HCL.
# ===========================================================================

# ---- Multi-tag (default) model ----
variable "required_tag_keys" {
  type        = list(string)
  description = "Tag keys a cluster MUST carry a (non-empty) value for. Omitting any of them is rejected at cluster create."
  default     = ["cost_center", "project"]
}

variable "allowlist_tags" {
  type        = map(list(string))
  description = "Tag key => allowed values. The cluster must set the tag to one of these values; any other value is rejected."
  default = {
    department = ["ENGINEERING", "FINANCE", "MARKETING", "IT_OPS", "SHARED"]
  }
}

# ---- Legacy single compound-tag model (opt-in) ----
variable "use_legacy_single_tag" {
  type        = bool
  description = <<-EOT
    When true, the cluster policy enforces ONE compound tag instead of the
    multi-tag model above. The legacy format packs everything into the value
    as key:value pairs joined by '+', e.g.
      cost_center:jdoe+billing_code:1234+user_id:42+user_name:jdoe+resource_type:cluster+resource_id:abc+resource_name:etl+project_name:analytics
  EOT
  default     = false
}

variable "legacy_tag_key" {
  type    = string
  default = "usage_info"
}

variable "legacy_tag_regex" {
  type        = string
  description = "Regex the compound value must match. Default requires at least cost_center:<something> to be present."
  default     = ".*cost_center:[^+]+.*"
}

# ---- Classic cluster policy knobs ----
variable "create_cluster_policy" {
  type    = bool
  default = true
}

variable "cluster_policy_name" {
  type    = string
  default = "finops-governed"
}

variable "cluster_policy_max_dbus_per_hour" {
  type        = number
  description = "Upper bound on DBU/hour for clusters using this policy (cost guardrail)."
  default     = 50
}

variable "autotermination_max_minutes" {
  type        = number
  description = "Max idle auto-termination allowed (cost guardrail)."
  default     = 120
}

# ---- Governed UC tags (companion, data-asset governance) ----
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
  description = "Governed UC tag policies. Empty values = any value allowed for that key."
  default = [
    {
      tag_key     = "department"
      description = "Example department (governed UC tag) -- companion to the compute allowlist."
      values      = ["ENGINEERING", "FINANCE", "MARKETING", "IT_OPS", "SHARED"]
    }
  ]
}

# ---- Serverless usage / budget policy (carries tags onto serverless spend) ----
variable "create_budget_policy" {
  type    = bool
  default = true
}

variable "budget_policy_name" {
  type        = string
  description = "Name of the serverless usage/budget policy. Must be unique in the account."
  default     = "finops-serverless"
}

variable "budget_policy_tags" {
  type        = map(string)
  description = "Fixed key=value tags attributed to serverless usage billed under this policy."
  default = {
    cost_center = "unassigned"
    project     = "unassigned"
    department  = "SHARED"
  }
}

variable "budget_binding_workspace_ids" {
  type        = list(number)
  description = "Workspaces this budget policy is bound to. Empty = available to all workspaces in the account."
  default     = []
}
