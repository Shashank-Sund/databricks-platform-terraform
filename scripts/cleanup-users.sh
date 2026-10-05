#!/usr/bin/env bash
# Hard-delete account users left DISABLED after `terraform destroy`.
#
# Terraform destroy only DEACTIVATES account users (SCIM soft-delete); they
# remain in the account as active=false. This permanently removes the
# disposable ones whose username starts with a namespace prefix.
#
# usage: cleanup-users.sh <account-cli-profile> [username-prefix]
#        cleanup-users.sh my-account-profile zz-tfdemo-
set -euo pipefail

PROFILE="${1:-}"
PREFIX="${2:-zz-tfdemo-}"

if [[ -z "$PROFILE" ]]; then
  echo "usage: $0 <account-cli-profile> [username-prefix]" >&2
  exit 1
fi

echo "Scanning account profile '${PROFILE}' for inactive users matching '${PREFIX}*'..."
databricks account users list -p "$PROFILE" --output json \
  | PREFIX="$PREFIX" python3 -c "
import os, sys, json
prefix = os.environ['PREFIX']
for u in json.load(sys.stdin):
    name = u.get('userName', '')
    if name.startswith(prefix) and not u.get('active', True):
        print(u['id'], name)
" \
  | while read -r id name; do
      echo "  deleting ${name} (${id})"
      databricks account users delete "$id" -p "$PROFILE"
    done

echo "Done."
