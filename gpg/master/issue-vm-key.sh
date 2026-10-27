#!/usr/bin/env bash
# LOCAL-ONLY. Must never run on ADM or any VM — the master GPG key never
# leaves this machine. Issues a dedicated GPG key for a given VM id,
# optionally signed by the master key, and exports the private key material
# for delivery (see ../delivery/first-bootstrap.md for how it then gets to
# the VM — that step is manual, not part of this script).
set -euo pipefail

if [[ "${GANIEVRF_ADM_MARKER:-}" == "1" ]]; then
  echo "Refusing to run: this looks like a VM/ADM environment, not the local master machine." >&2
  exit 1
fi

VM_ID="${1:-}"
if [[ -z "${VM_ID}" ]]; then
  echo "Usage: $0 <vm-id>" >&2
  exit 1
fi

if [[ "${GANIEVRF_MAKE_ASK_SKIP:-no}" != "yes" ]]; then
  read -r -p "Issue a new GPG key for VM '${VM_ID}' from the local master key — apply? [y/N] " ans
  case "${ans}" in
    [yY]*) ;;
    *) echo "Aborted." ; exit 1 ;;
  esac
fi

KEY_UID="adm-vm-${VM_ID}"
OUT_DIR="$(mktemp -d)"
trap 'rm -rf "${OUT_DIR}"' EXIT

gpg --batch --quick-generate-key "${KEY_UID}" default default never

FPR="$(gpg --list-keys --with-colons "${KEY_UID}" | awk -F: '/^fpr:/{print $10; exit}')"

# Sign with the master key for a trust chain (requires the master key to be
# the default/designated signing key in this gpg homedir).
gpg --batch --yes --sign-key "${FPR}" || echo "WARN: could not sign with master key — check gpg --list-secret-keys" >&2

gpg --batch --yes --armor --export-secret-keys "${FPR}" > "${OUT_DIR}/${KEY_UID}.asc"

echo "Issued key for ${VM_ID}: ${FPR}"
echo "Private key exported to: ${OUT_DIR}/${KEY_UID}.asc"
echo "Deliver it to the VM manually — see ../delivery/first-bootstrap.md."
echo "This script does not copy it anywhere itself."
