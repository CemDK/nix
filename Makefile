SHELL := /usr/bin/env bash

HOSTNAME      := $(shell hostname -s)
UNAME         := $(shell uname)
LOG           := /tmp/nixos-build.log
SECRETS_DIR   := secrets
HOMELAB_USER  := cemdk
HOMELAB_HOST  := $(HOMELAB_USER)@nixos.local
HOMELAB_FLAKE := wyse-5070
NH            := $(shell command -v nh 2>/dev/null || echo "nix run nixpkgs\#nh --")

# DARWIN:
ifeq ($(UNAME),Darwin)
  SWITCH_CMD := $(NH) darwin switch .
# NIXOS:
else ifneq ($(wildcard /etc/NIXOS),)
  SWITCH_CMD := $(NH) os switch .
# GENERIC LINUX (home-manager):
else
  SWITCH_CMD := $(NH) home switch .
endif

.PHONY: bootstrap check lint switch update clean iso secrets secrets-homelab rekey sync deploy

# ============================================================================
# BOOTSTRAP
# ============================================================================
# One-time setup for generic Linux: ensures the system-wide nix.conf has the
# experimental features the daemon needs (NixOS/Darwin manage this declaratively).
bootstrap:
	@if [ "$(UNAME)" = "Darwin" ]; then \
		echo "Skip: nix-darwin manages /etc/nix/nix.conf"; exit 0; \
	fi; \
	if [ -f /etc/NIXOS ]; then \
		echo "Skip: NixOS manages /etc/nix/nix.conf via nix.settings"; exit 0; \
	fi; \
	if sudo grep -Eq '^experimental-features[[:space:]]*=.*\bnix-command\b.*\bflakes\b' /etc/nix/nix.conf 2>/dev/null; then \
		echo "experimental-features already set in /etc/nix/nix.conf"; \
	else \
		echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf >/dev/null; \
		echo "Appended experimental-features to /etc/nix/nix.conf"; \
		sudo systemctl restart nix-daemon; \
		echo "nix-daemon restarted"; \
	fi

# ============================================================================
# NIX
# ============================================================================
check:
	@nix flake check --all-systems 2>&1 | tee $(LOG)

lint:
	@statix check .
	@nix fmt -- --fail-on-change .

switch:
	@$(SWITCH_CMD)

update:
	@nix flake update
	@$(SWITCH_CMD)

clean:
	@$(NH) clean all --keep 5 --keep-since 7d

iso:
	@HOST=$${HOST:-thinkpad}; \
	echo "Building ISO for $$HOST..."; \
	nix build --impure --expr " \
		let flake = builtins.getFlake \"path:$(CURDIR)\"; \
		in (flake.inputs.nixpkgs.lib.nixosSystem { \
			system = \"x86_64-linux\"; \
			modules = [({ modulesPath, ... }: { \
				imports = [ \
					(modulesPath + \"/installer/cd-dvd/installation-cd-minimal.nix\") \
					\"\$${flake.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix\" \
					$(CURDIR)/hosts/nixos/iso/configuration.nix \
				]; \
				isoImage.storeContents = [ \
					flake.nixosConfigurations.$$HOST.config.system.build.toplevel \
				]; \
			})]; \
		}).config.system.build.isoImage" \
		-o result-iso 2>&1 | tee $(LOG); \
	echo "ISO written to result-iso/iso/"

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
