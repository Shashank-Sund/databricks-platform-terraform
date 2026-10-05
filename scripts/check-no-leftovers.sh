#!/usr/bin/env bash
# Post-teardown safety check: prove NO namespaced test resources remain.
# Exits non-zero if any zz-tfdemo* / zz_tfdemo* resource is found.
#
# usage: check-no-leftovers.sh <account-profile> <workspace-profile> [catalog]
#        check-no-leftovers.sh my-account-profile my-workspace-profile my_catalog
set -uo pipefail

ACCT="${1:?account CLI profile required (arg 1)}"
WS="${2:?workspace CLI profile required (arg 2)}"
CATALOG="${3:-}"
PAT="zz-tfdemo\|zz_tfdemo"
fail=0

check() {
  local label="$1" count="$2"
  printf '  %-32s %s\n' "$label" "$count"
  [[ "$count" -ne 0 ]] && fail=1
  return 0
}

echo "Leftover scan (pattern: zz-tfdemo* / zz_tfdemo*)"

echo "account [$ACCT]"
check "groups" "$(databricks account groups list -p "$ACCT" --output json 2>/dev/null | grep -c "$PAT")"
check "users (active or disabled)" "$(databricks account users list -p "$ACCT" --output json 2>/dev/null | grep -c "$PAT")"

echo "workspace [$WS]"
check "cluster policies" "$(databricks cluster-policies list -p "$WS" --output json 2>/dev/null | grep -c "$PAT")"

if [[ -n "$CATALOG" ]]; then
  check "schemas in $CATALOG" "$(databricks schemas list "$CATALOG" -p "$WS" --output json 2>/dev/null | grep -c "$PAT")"
fi

echo
if [[ "$fail" -eq 0 ]]; then
  echo "CLEAN: no zz-tfdemo* / zz_tfdemo* resources remain."
  exit 0
else
  echo "LEFTOVERS FOUND -- investigate above." >&2
  exit 1
fi
