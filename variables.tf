# ---------------------------------------------------------------------------
# Shared variable contracts (reference)
#
# These are the common connection + targeting variables used across the
# examples. Copy the ones you need into each runnable config, or treat this
# file as documentation of the contract. Nothing here creates resources.
# ---------------------------------------------------------------------------

variable "account_id" {
  type        = string
  description = "Databricks account ID (UUID). Required for account-level operations. May be null if supplied by the CLI profile."
  default     = null
}

variable "account_host" {
  type        = string
  description = "Account console URL."
  default     = "https://accounts.cloud.databricks.com"
}

variable "account_profile" {
  type        = string
  description = "Named ~/.databrickscfg profile for the ACCOUNT provider (local dev). Leave null to use OAuth env vars."
  default     = null
}

variable "workspace_host" {
  type        = string
  description = "Target workspace URL, e.g. https://dbc-xxxx.cloud.databricks.com . This is how you target dev vs prod vs any existing workspace."
  default     = null
}

variable "workspace_profile" {
  type        = string
  description = "Named ~/.databrickscfg profile for the WORKSPACE provider (local dev). Leave null to use OAuth env vars."
  default     = null
}

variable "environment" {
  type        = string
  description = "Free-form environment label (dev / prod / sandbox). Used only for naming + tagging; it does NOT create workspaces."
  default     = "dev"

  validation {
    condition     = length(var.environment) > 0
    error_message = "environment must not be empty."
  }
}
