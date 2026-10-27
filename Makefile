# Same conventions as ansible/Makefile: no ssh dispatch, confirmation
# prompts skippable via GANIEVRF_MAKE_ASK_SKIP=yes. gpg-issue-vm-key is the
# one strictly local-only target — see AGENTS.md and gpg/master/.

SHELL := /bin/bash
.DEFAULT_GOAL := help

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  SED  := gsed
  GREP := ggrep
else
  SED  := sed
  GREP := grep
endif

.PHONY: help _detect-os secrets gpg-issue-vm-key

help:
	@echo "Targets: secrets, gpg-issue-vm-key VM=<vm-id>"
	@echo "Set GANIEVRF_MAKE_ASK_SKIP=yes to skip confirmation prompts (automation mode)."

_detect-os:
	@command -v $(SED) >/dev/null 2>&1 || { echo "Missing $(SED); on macOS: brew install gnu-sed"; exit 1; }
	@command -v $(GREP) >/dev/null 2>&1 || { echo "Missing $(GREP); on macOS: brew install grep"; exit 1; }
	@case "$(MAKE_VERSION)" in \
		"") echo "ERROR: not running under GNU Make (MAKE_VERSION is unset)."; \
		    echo "On macOS this Makefile only parses correctly under GNU Make: brew install make, then run 'gmake' instead of 'make'."; \
		    exit 1 ;; \
		*) echo "OK: running under GNU Make $(MAKE_VERSION) (invoked as '$(MAKE)')." ;; \
	esac
ifeq ($(UNAME_S),Darwin)
	@case "$(MAKE)" in \
		*gmake*) ;; \
		*) echo "WARNING: on macOS, invoke this Makefile as 'gmake', not 'make' (Homebrew GNU Make)." ;; \
	esac
endif

# Creates/rotates cloud + external secrets on whatever machine this runs on.
secrets: _detect-os
	./providers/yandex_cloud/create-secrets.sh
	./external/github/update-secrets.sh

# Local-only: must run on the user's own machine, never on a VM.
gpg-issue-vm-key: _detect-os
	@[ -n "$(VM)" ] || { echo "Usage: make gpg-issue-vm-key VM=<vm-id>"; exit 1; }
	./gpg/master/issue-vm-key.sh "$(VM)"
