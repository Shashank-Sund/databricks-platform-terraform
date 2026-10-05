# Terraform always owns the group itself.
resource "databricks_group" "this" {
  provider     = databricks.account
  display_name = var.group_name
}

# Pattern A: Terraform owns users (no SCIM). Creates each user.
resource "databricks_user" "this" {
  provider  = databricks.account
  for_each  = var.scim_managed_users ? toset([]) : toset(var.member_emails)
  user_name = each.value
}

# Pattern B: SCIM owns users. Terraform only reads them (never creates/edits),
# so it does not fight the IdP sync. Plan fails loudly if a user is missing,
# which correctly surfaces "SCIM has not provisioned this person yet".
data "databricks_user" "existing" {
  provider  = databricks.account
  for_each  = var.scim_managed_users ? toset(var.member_emails) : toset([])
  user_name = each.value
}

locals {
  member_ids = var.scim_managed_users ? {
    for e, u in data.databricks_user.existing : e => u.id
    } : {
    for e, u in databricks_user.this : e => u.id
  }
}

# Membership is Terraform-owned in BOTH patterns.
resource "databricks_group_member" "this" {
  provider  = databricks.account
  for_each  = local.member_ids
  group_id  = databricks_group.this.id
  member_id = each.value
}
