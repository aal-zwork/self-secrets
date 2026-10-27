#!/usr/bin/env bash
# Creates/rotates Yandex Cloud secrets used by this infrastructure, using
# the already-privileged `yc` identity (ADM's admin service account — see
# ansible/roles/providers/yandex_cloud/tasks/authenticate.yml). Does not
# authenticate `yc` itself.
#
# Idempotent: safe to re-run. Delegates actual rotation to update-secrets.sh
# so both entrypoints share one interface.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${GANIEVRF_MAKE_ASK_SKIP:-no}" != "yes" ]]; then
  read -r -p "Create/rotate yandex_cloud secrets — apply? [y/N] " ans
  case "${ans}" in
    [yY]*) ;;
    *) echo "Aborted." ; exit 1 ;;
  esac
fi

command -v yc >/dev/null 2>&1 || { echo "yc CLI not found on PATH" >&2; exit 1; }
command -v pass >/dev/null 2>&1 || { echo "pass not found on PATH" >&2; exit 1; }

"${SCRIPT_DIR}/update-secrets.sh"
