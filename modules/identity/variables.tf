variable "group_name" {
  type        = string
  description = "Display name of the account group Terraform creates and owns (e.g. a cohort or team)."
}

variable "member_emails" {
  type        = list(string)
  description = "Emails/usernames to place in the group."
  default     = []
}

variable "scim_managed_users" {
  type        = bool
  description = <<-EOT
    How users are owned:
      false (default) -> Terraform CREATES and owns the users (databricks_user).
                         For an account with manual onboarding, no SCIM sync.
      true            -> An external IdP/SCIM (Entra and/or Okta) provisions the
                         users. Terraform does NOT create them; it looks them up
                         via data.databricks_user and only manages group
                         membership. This avoids fighting the SCIM sync.
    Either way Terraform always owns the GROUP, the MEMBERSHIP, entitlements,
    grants and policies.
  EOT
  default     = false
}
