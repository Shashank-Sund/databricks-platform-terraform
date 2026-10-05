# Databricks Platform Terraform

Set up and govern Databricks with code instead of clicking through the console.
This repo lets you:

- **Onboard people** (one at a time, or a whole cohort such as a class, a
  hackathon, or a team) in a single command, and remove them just as easily.
- **Enforce cost tagging** so every piece of compute is attributable for FinOps
  and chargeback.

Everything is parameterized: you fill in a few values and run. It is deliberately
generic, with nothing organization-specific baked in. Every example value is a
placeholder meant to be replaced with your own.

> This repo works on **existing** Databricks workspaces. It does **not** create
> workspaces. You point it at a workspace you already have (dev, prod, or any
> other).

---

## New to Terraform? Read this first (about 5 minutes)

**What Terraform is.** Normally you set Databricks up by clicking around the
admin console: create a group, add users, grant permissions, one at a time.
Terraform replaces that with a text file. You write down *what you want to
exist* (this group, these users, these grants), run one command, and Terraform
makes reality match the file. Edit the file and run again to change things. Run
one more command to tear it all down.

**The mental model.** You describe the desired end state, not the click-by-click
steps. Terraform compares your file against what already exists and works out the
minimum set of changes. It records what it built in a *state file* so it knows
what it owns and can update or remove it later.

**The four commands you will use** (always in this order):

| Command | What it does |
|---|---|
| `terraform init` | One-time setup in a folder. Downloads the Databricks provider. |
| `terraform plan` | Shows exactly what it *would* create, change, or destroy. Changes nothing. |
| `terraform apply` | Makes the changes (asks you to type `yes` first). |
| `terraform destroy` | Removes everything this configuration created. |

Rule of thumb: **always run `plan` and read it before `apply`.** `plan` is
read-only and safe to run as often as you like.

**Why use it instead of clicking:**

- **Repeatable:** the same file produces the same setup every time, in dev and in
  prod.
- **Reviewable:** a change is a diff your team can read and approve before
  anything happens.
- **Reversible:** `destroy` cleans everything up, so test setups and hackathons
  leave nothing behind.
- **Auditable:** the file is a living record of who has access to what.

**Where Terraform fits well:**

- Repeatable account and workspace setup: groups, users, entitlements, grants,
  policies.
- Onboarding and offboarding people, especially in batches.
- Governance you want enforced and version-controlled (like the cost-tag
  policies in this repo).

**Where it is not the right tool:**

- One-off exploration or a quick manual experiment. Just use the console.
- Running data pipelines or queries. That is Jobs, notebooks, and pipelines, not
  Terraform.
- Anything with no Databricks API behind it. Terraform can only manage what the
  provider supports.

**Two safety rules:**

1. For anything automated, authenticate with a **service principal**, not your
   personal token.
2. Terraform's **state file** and your real **variable values** can contain
   sensitive data. **Never commit them.** This repo's `.gitignore` already blocks
   `*.tfstate` and `*.tfvars`.

---

## Quickstart (60 seconds)

If you just want to see it work:

1. Install **Terraform** and the **Databricks CLI**. Have your Databricks
   **account ID** and a way to log in (a CLI profile or a service principal).
2. `cd examples/onboard-one-user`
3. `cp terraform.tfvars.example terraform.tfvars`, then edit it: set your login
   (uncomment the Option A profile lines, or use Option B for a service
   principal), your `workspace_id`, a `grant_catalog` you own, and the group name
   and member.
4. `terraform init`, then `terraform plan` (read it), then `terraform apply`.
5. Look at the new group, user, and grant in the Databricks console. When you are
   done, `terraform destroy`.

The rest of this README explains each piece.

---

## What this repo does

Three jobs, each with a ready-to-run example:

1. **Onboard one person, end to end.** Create a group, put the person in it,
   assign the group to a workspace, give it entitlements, and grant it Unity
   Catalog access. (`examples/onboard-one-user`)
2. **Onboard a whole cohort at once.** The same for many people in a single apply
   (a class, a hackathon, a team), and also grant them access to a compute policy,
   with a clean one-command teardown. (`examples/onboard-cohort`)
3. **Enforce FinOps cost tagging.** A policy that *requires* your cost tags on
   compute, so nothing runs untagged and all spend is attributable.
   (`examples/finops-enforcement`)

It is built from small, reusable **modules** that the **examples** wire together.
You run the examples; the modules are the building blocks underneath.

---

## Prerequisites

- **Terraform** >= 1.5 and the **Databricks CLI** installed.
- The **`databricks/databricks` provider** >= 1.84 (tested on 1.135.0).
  `terraform init` downloads this for you.
- Your **account ID** (a UUID) for account-level actions (groups, users,
  workspace assignment, budget policies).
- **Authentication at two scopes.** Account-level actions talk to
  `accounts.cloud.databricks.com`; workspace-level actions talk to a specific
  workspace URL. Pick one method per scope:
  - **Service principal (recommended for automation and prod):** give it account
    admin, set the account ID and hosts, and export `DATABRICKS_CLIENT_ID` and
    `DATABRICKS_CLIENT_SECRET`.
  - **Named CLI profile (easy for local use):** set `account_profile` and
    `workspace_profile` to profiles in your `~/.databrickscfg`.
- For real (non-throwaway) use, a **remote state backend** (for example an S3
  bucket with a DynamoDB lock table). Add a `backend "s3" { ... }` block to the
  example you run. For a quick local test you can skip this.

---

## Repo layout

```
.
├── versions.tf            # provider source + version floor (reference)
├── providers.tf           # dual-provider template (account + workspace)
├── variables.tf           # shared connection / targeting variables (reference)
├── modules/
│   ├── identity/          # group + users (SCIM-aware) + membership
│   ├── onboarding/        # workspace assignment + entitlements + UC grants + cluster-policy access
│   ├── finops-tagging/    # cluster policy (classic) + budget policy (serverless) + governed UC tags
│   └── cohort/            # identity + onboarding composed, for cohorts / teams
├── examples/
│   ├── onboard-one-user/  # one person, end to end (start here)
│   ├── onboard-cohort/    # a whole cohort in one apply
│   ├── finops-enforcement/# the cost-tag governance stack
│   └── teardown/          # how to destroy cleanly
├── scripts/
│   ├── cleanup-users.sh       # hard-delete deactivated namespaced users
│   └── check-no-leftovers.sh  # prove no test resources remain
└── .github/workflows/validate.yml  # fmt-check + validate on every example
```

- **modules/** are the reusable building blocks. You usually do not edit these.
- **examples/** are runnable configurations that wire the modules together with
  real values. **This is what you run.**
- **scripts/** are small helpers for cleaning up after a teardown.

---

## The run sequence (step by step)

Every example is self-contained and run from **its own folder**. The pattern is
always the same:

```bash
cd examples/<the-example-you-want>
cp terraform.tfvars.example terraform.tfvars   # then edit it with your values
terraform init      # once per folder
terraform plan      # read what it will do
terraform apply     # type 'yes' to confirm
# ... verify in the Databricks console ...
terraform destroy   # when you want to remove it
```

For a quick local run you can skip the tfvars file and pass values on the command
line instead:

```bash
terraform apply \
  -var account_profile=<your-account-profile> \
  -var account_id=<your-account-uuid> \
  -var workspace_profile=<your-workspace-profile> \
  -var workspace_id=<your-workspace-id> \
  -var grant_catalog=<a catalog you own>
```

**Suggested order to learn the repo:**

1. Start with **onboard-one-user**. It is the smallest end-to-end flow and shows
   every moving part once.
2. Then **onboard-cohort**, once you want to do many people at a time.
3. Then **finops-enforcement**, when you are ready to add cost-tag governance.

---

## The examples

- **onboard-one-user** - creates a group with one member, assigns it to a
  workspace, sets entitlements, and creates a throwaway schema in a catalog you
  own so you can watch a Unity Catalog grant land. The simplest full example.
- **onboard-cohort** - the hackathon or class pattern. Put everyone's emails in
  `member_emails` and apply. To offboard, remove emails and apply again, or
  `destroy` the whole cohort. Also attaches the cohort to a compute policy.
- **finops-enforcement** - stands up the cost-tag governance stack (details
  below).
- **teardown** - not a configuration; a short guide to destroying cleanly,
  including the one manual user-cleanup step.

---

## FinOps: how cost-tag enforcement works

Cost tags only reach your **bill** through **compute**, so enforcement happens on
the two compute paths, with a companion for data governance:

| Path | Resource | What it does |
|---|---|---|
| Classic compute | `databricks_cluster_policy` | **Requires** the cost tags when a cluster is created. A cluster missing a required tag, or using a `department` value outside the allowlist, is rejected. |
| Serverless compute | `databricks_budget_policy` | Attaches fixed tags to serverless usage so that spend is attributed. |
| Data governance (companion) | `databricks_tag_policy` | Governed Unity Catalog tags: a central allow-list of values for a tag key on catalogs, schemas, and tables. Not a billing path. |

The defaults are an **example** taxonomy; replace them with your own via variables
(you should not need to edit any HCL):

- **Required** (must be present on every cluster): `cost_center`, `project`.
- **Allowlisted** (`department` must be one of): `ENGINEERING`, `FINANCE`,
  `MARKETING`, `IT_OPS`, `SHARED`.
- A **legacy single-tag mode** is available (`use_legacy_single_tag = true`) for
  organizations that pack everything into one tag's value as `key:value` pairs
  joined by `+`.

To let a group launch only governed, correctly-tagged compute, grant them access
to the policy through the onboarding module (`grant_cluster_policy_access = true`
with `cluster_policy_id`).

---

## Identity: Terraform vs SCIM (read before onboarding users)

**SCIM** is how an identity provider (Entra ID, Okta, and so on) automatically
pushes users and groups into Databricks. If SCIM is running, that identity
provider owns *who exists*, and it keeps re-syncing.

If Terraform also tried to create those same users, the two would fight. So the
rule is: **whoever provisions the users owns them; the other side must not.** This
repo supports both, via one flag:

- `scim_managed_users = false` **(default)** - Terraform creates and owns the
  users. `destroy` deactivates them (then hard-delete them with the cleanup
  script).
- `scim_managed_users = true` - an identity provider already provisions the
  users. Terraform does not create them; it only looks them up and manages group
  membership, entitlements, grants, and policies. `destroy` leaves those users
  untouched. If a user has not been synced yet, `plan` fails clearly so you know.

Either way, Terraform always owns the **group**, its **membership**,
**entitlements**, **grants**, and **policies**. Only *user ownership* changes.

---

## Teardown

Each example owns its own state, so tear it down from its own folder:

```bash
cd examples/<the-example>
terraform destroy
```

`terraform destroy` only **deactivates** account users (a soft delete). To
permanently remove the disposable ones, run this from the repo root:

```bash
./scripts/cleanup-users.sh <account-profile> zz-tfdemo-
```

It hard-deletes inactive users whose name starts with the prefix you pass. Then
confirm nothing is left, also from the repo root:

```bash
./scripts/check-no-leftovers.sh <account-profile> <workspace-profile>
```

SCIM-managed users are never touched by `destroy`, so there is nothing to clean up
for them.

---

## FAQ

- **Do I have to run `plan` before `apply`?** Not strictly, but always do it.
  `plan` shows exactly what will change and alters nothing; it is your safety
  check.
- **What is the state file?** Terraform's record of what it created, so it knows
  what to update or destroy later. It can hold sensitive values, so it is
  gitignored and, for real use, should live in a remote backend.
- **Can I run this against production?** Yes. "dev vs prod" is simply which
  workspace you target (`workspace_id` plus the workspace provider). The repo does
  not create workspaces.
- **A user already exists via our identity provider. Will this clobber them?** No.
  Set `scim_managed_users = true` and Terraform will only read those users.
- **What do the scripts do?** `cleanup-users.sh` hard-deletes the disposable users
  left deactivated after a destroy. `check-no-leftovers.sh` confirms no test
  resources remain.
