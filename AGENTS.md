# AGENTS.md — secrets/

This directory is a draft of a future standalone repository responsible for
the secrets lifecycle: creating/rotating cloud secrets in Yandex Cloud,
external secrets (GitHub), storing them encrypted in S3 via `pass`
(passwordstore.org), and issuing per-VM GPG keys from a local master key.

## Hard boundary: local-only vs remote

- `gpg/master/` is **strictly local-only**. It must only ever run on the
  user's own machine, never on ADM or any VM. The master GPG key never
  leaves the local machine — not even encrypted, not even transiently.
  If a script under `gpg/master/` is somehow invoked on a remote host, it
  must fail loudly and immediately, not attempt to proceed.
- `gpg/delivery/` describes the manual, out-of-band step of getting an
  already-issued VM key onto that VM. This step is intentionally not
  automated — until the VM has its key, it cannot decrypt the pass-store
  pulled from S3 (chicken-and-egg).
- `providers/<name>/` and `external/<name>/` scripts are plain bash — unlike
  `ansible/`, there is **no remote-execution layer here at all** (no
  `ansible-playbook` underneath). `./providers/yandex_cloud/create-secrets.sh`
  runs `yc`/`pass` directly on whatever machine invoked `make secrets`. In
  practice that means the operator must `ssh yandex-cloud-adm` first and run
  `make secrets` there — running it from a laptop would use the operator's
  personal `yc` auth instead of ADM's admin service account. The one target
  that must run the other way (always locally, never on ADM) is
  `gpg-issue-vm-key`.

## Secret layout convention

- Pass-store paths are provider-namespaced: `providers/<provider>/<kind>/<name>`
  for cloud secrets, `external/<system>/<name>` for everything else (e.g.
  `external/github/deploy-key`).
- Every provider/external secret source exposes the same two operations:
  create (idempotent) and `update-secrets.sh` (rotation). Do not add a
  one-off script that only creates a secret without an update path.
- `yc` on ADM already runs as an admin service account — scripts under
  `providers/yandex_cloud/` use that identity to create *other* secrets
  (S3 static keys, SA keys for k8s workloads); they do not need to
  authenticate `yc` itself.

## Makefile conventions

- Same rules as `ansible/AGENTS.md`: no ssh dispatch inside `Makefile`
  itself, `_detect-os` picks `gmake`/`gsed`/`ggrep` on macOS vs native GNU
  tools on Ubuntu, prints the running `make` version/binary and warns if
  Darwin's old GNU Make 3.81 is used instead of Homebrew's `gmake`, every
  mutating target asks for confirmation unless `GANIEVRF_MAKE_ASK_SKIP=yes`.
- The one exception: GPG master-key targets are local-only by design (see
  above) — they do not need OS detection beyond "refuse to run as root/on a
  VM marker if one is ever introduced", and they still respect the
  confirmation prompt convention.

## Adding a new provider or external system

- New cloud provider: add `providers/<name>/{create-secrets.sh,update-secrets.sh,layout.md}`
  following the same interface as `providers/yandex_cloud/`.
- New external system: add `external/<name>/{update-secrets.sh,layout.md}`
  (plus any manual issuance doc, like `external/github/issue-deploy-key.md`).
- See `../docs/provider-abstraction.md` for how this interacts with
  `ansible/roles/providers/<name>/`.
