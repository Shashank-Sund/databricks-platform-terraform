locals {
  # Required (free-value) tags: must be present, non-empty. isOptional=false
  # forces the user to supply a value at cluster-create time.
  required_tag_defs = var.use_legacy_single_tag ? {
    "custom_tags.${var.legacy_tag_key}" = {
      type       = "regex"
      pattern    = var.legacy_tag_regex
      isOptional = false
    }
    } : {
    for k in var.required_tag_keys :
    "custom_tags.${k}" => {
      type       = "regex"
      pattern    = ".+"
      isOptional = false
    }
  }

  # Allowlisted tags: value must be one of the allowed set (skipped in legacy mode).
  allowlist_tag_defs = var.use_legacy_single_tag ? {} : {
    for k, vals in var.allowlist_tags :
    "custom_tags.${k}" => {
      type       = "allowlist"
      values     = vals
      isOptional = false
    }
  }

  # Cost guardrails.
  base_defs = {
    autotermination_minutes = {
      type         = "range"
      maxValue     = var.autotermination_max_minutes
      defaultValue = min(30, var.autotermination_max_minutes)
    }
    dbus_per_hour = {
      type     = "range"
      maxValue = var.cluster_policy_max_dbus_per_hour
    }
  }

  cluster_policy_definition = merge(local.base_defs, local.required_tag_defs, local.allowlist_tag_defs)
}

# CLASSIC compute enforcement.
resource "databricks_cluster_policy" "this" {
  provider   = databricks.workspace
  count      = var.create_cluster_policy ? 1 : 0
  name       = var.cluster_policy_name
  definition = jsonencode(local.cluster_policy_definition)
}

# Governed UC tags (companion). Empty values => no value restriction.
resource "databricks_tag_policy" "governed" {
  provider    = databricks.workspace
  for_each    = var.create_governed_tags ? { for tp in var.governed_tag_policies : tp.tag_key => tp } : {}
  tag_key     = each.value.tag_key
  description = each.value.description
  values      = length(coalesce(each.value.values, [])) > 0 ? [for v in each.value.values : { name = v }] : null
}

# SERVERLESS compute enforcement / attribution (the serverless "usage policy").
resource "databricks_budget_policy" "this" {
  provider              = databricks.account
  count                 = var.create_budget_policy ? 1 : 0
  policy_name           = var.budget_policy_name
  binding_workspace_ids = var.budget_binding_workspace_ids
  custom_tags           = [for k, v in var.budget_policy_tags : { key = k, value = v }]
}
