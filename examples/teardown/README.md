# Teardown

There is no separate "teardown" Terraform config. Each example owns its own
state, so you tear an example down from **its own directory**:

```bash
cd examples/onboard-cohort
terraform destroy   # pass the same -var / -var-file you applied with
```

`terraform destroy` removes every resource that example created: groups,
memberships, workspace assignments, entitlements, UC grants, cluster policies,
tag policies, budget policies, and any demo schema.

## The one manual step: account users

Destroying a `databricks_user` only **deactivates** the account user (SCIM
soft-delete) -- they linger in the account as `active: false`. This is
Databricks behaviour, not a Terraform bug. To permanently remove the disposable
users an example created, run the helper after `destroy`:

```bash
../../scripts/cleanup-users.sh <account-cli-profile> zz-tfdemo-
# e.g. ../../scripts/cleanup-users.sh my-account-profile zz-tfdemo-
```

It finds inactive users whose username starts with the prefix you pass and
hard-deletes them. Use a namespace prefix you are certain is disposable.

> SCIM-owned users (`scim_managed_users = true`) are **never** touched by
> destroy -- Terraform only read them -- so there is nothing to clean up for
> them.

## Prove nothing is left

```bash
../../scripts/check-no-leftovers.sh <account-profile> <workspace-profile>
```

Exits non-zero if any `zz-tfdemo*` / `zz_tfdemo*` group, user, or cluster
policy still exists.
