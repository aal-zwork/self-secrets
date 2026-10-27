#!/usr/bin/env bash
# Shared create/rotate interface for yandex_cloud secrets. See layout.md
# for the pass-store path convention. Extend this script (and layout.md)
# together when adding a new secret kind — do not add a one-off script
# elsewhere.
set -euo pipefail

PASS_PREFIX="providers/yandex_cloud"

# TODO: replace with real `yc` commands once bucket/SA names are finalized.
# Example shape for a static S3 access key rotation:
#
#   NEW_KEY_JSON="$(yc iam access-key create --service-account-name adm-s3-writer --format json)"
#   KEY_ID="$(jq -r '.access_key.key_id' <<<"${NEW_KEY_JSON}")"
#   SECRET="$(jq -r '.secret' <<<"${NEW_KEY_JSON}")"
#   printf '%s\n' "${KEY_ID}:${SECRET}" | pass insert -m -f "${PASS_PREFIX}/s3/pass-store-access-key"
#
# After updating pass, push the pass-store git remote so S3 has the new
# encrypted blob (disaster-recovery source of truth):
#
#   git -C "${PASS_STORE_LOCAL_PATH:-$HOME/.password-store}" push

echo "TODO: implement yandex_cloud secret creation/rotation (see comments in this script)."
echo "Pass-store prefix for this provider: ${PASS_PREFIX}"
