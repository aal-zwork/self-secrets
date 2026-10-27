#!/usr/bin/env bash
# Shared create/rotate interface for external GitHub secrets. See
# layout.md for the pass-store path convention and issue-deploy-key.md for
# the (unconfirmed) issuance procedure.
set -euo pipefail

PASS_PATH="external/github/deploy-key"

if [[ "${GANIEVRF_MAKE_ASK_SKIP:-no}" != "yes" ]]; then
  read -r -p "Rotate GitHub deploy-key at pass:${PASS_PATH} — apply? [y/N] " ans
  case "${ans}" in
    [yY]*) ;;
    *) echo "Aborted." ; exit 1 ;;
  esac
fi

echo "TODO: this rotation is not yet implemented — see issue-deploy-key.md,"
echo "the issuance procedure needs confirmation before this script can act."
echo "Pass-store path: ${PASS_PATH}"
