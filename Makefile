SHELL := /usr/bin/env bash

HOSTNAME      := $(shell hostname -s)
UNAME         := $(shell uname)
LOG           := /tmp/nixos-build.log
SECRETS_DIR   := secrets
HOMELAB_USER  := cemdk
HOMELAB_HOST  := $(HOMELAB_USER)@nixos.local
HOMELAB_FLAKE := wyse-5070

# DARWIN:
ifeq ($(UNAME),Darwin)
  SWITCH_CMD := script -q $(LOG) sudo darwin-rebuild switch --flake .\#$(HOSTNAME)
# NIXOS:
else ifneq ($(wildcard /etc/NIXOS),)
  SWITCH_CMD := script -q --return -c "sudo nixos-rebuild switch --flake .\#$(HOSTNAME)" $(LOG)
# GENERIC LINUX (home-manager):
else
  SWITCH_CMD := script -q --return -c "nix --extra-experimental-features 'nix-command flakes' run nixpkgs\#home-manager -- switch --flake .\#$(HOSTNAME)" $(LOG)
endif

define on-failure
	if [ $$EXIT_CODE -ne 0 ]; then \
		echo ""; \
		echo "========================================"; \
		echo " Failed"; \
		echo "========================================"; \
		echo ""; \
		col -b < $(LOG) | claude --output-format text -p \
			"The nix command failed. Diagnose the root cause and explain what went wrong. Respond with plain text only - do not attempt to edit or create files." \
			> /tmp/nixos-claude.txt & \
		CLAUDE_PID=$$!; \
		printf "Asking Claude"; \
		while kill -0 $$CLAUDE_PID 2>/dev/null; do \
			printf "."; \
			sleep 1.5; \
		done; \
		wait $$CLAUDE_PID; \
		printf "\n\n"; \
		cat /tmp/nixos-claude.txt; \
		echo ""; \
	fi
endef

.PHONY: check switch secrets secrets-homelab rekey sync deploy

# ============================================================================
# NIX
# ============================================================================
check:
	@nix flake check --all-systems 2>&1 | tee $(LOG); EXIT_CODE=$${PIPESTATUS[0]}; \
	$(on-failure)

switch:
	@$(SWITCH_CMD); EXIT_CODE=$$?; \
	$(on-failure)

# ============================================================================
# SECRETS (sops)
# ============================================================================
secrets:
	sops $(SECRETS_DIR)/global.yaml

secrets-homelab:
	sops $(SECRETS_DIR)/homelab/secrets.yaml

rekey:
	@find $(SECRETS_DIR) -name "*.yaml" | xargs -I{} sops updatekeys --yes {}

# ============================================================================
# HOMELAB DEPLOY
# ============================================================================
sync:
	rsync -rltvz --mkpath --update \
		--exclude '.git' \
		--filter=':- .gitignore' \
		$(CURDIR)/ \
		$(HOMELAB_HOST):/home/$(HOMELAB_USER)/.config/nix/

# TODO: migrate to colmena
deploy: sync
	@nix shell nixpkgs\#nixos-rebuild --command nixos-rebuild switch \
		--flake .#$(HOMELAB_FLAKE) \
		--target-host $(HOMELAB_HOST) \
		--build-host $(HOMELAB_HOST) \
		--sudo \
		2>&1 | tee $(LOG); EXIT_CODE=$${PIPESTATUS[0]}; \
