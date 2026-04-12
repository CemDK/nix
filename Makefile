SHELL := /usr/bin/env bash

HOSTNAME := $(shell hostname -s)
UNAME    := $(shell uname)
LOG      := /tmp/nixos-build.log

ifeq ($(UNAME),Darwin)
  SWITCH_CMD := darwin-rebuild switch --flake .\#$(HOSTNAME)
else ifneq ($(wildcard /etc/NIXOS),)
  SWITCH_CMD := sudo nixos-rebuild switch --flake .\#$(HOSTNAME)
else ifeq ($(shell grep -q '^ID=nixos$$' /etc/os-release 2>/dev/null && echo yes),yes)
  SWITCH_CMD := sudo nixos-rebuild switch --flake .\#$(HOSTNAME)
else
  SWITCH_CMD := nix --extra-experimental-features 'nix-command flakes' run nixpkgs\#home-manager -- switch --flake .\#$(HOSTNAME)
endif

# script(1) creates a pseudo-TTY so spinners/progress work; argument order differs by platform
ifeq ($(UNAME),Darwin)
  SCRIPT_CMD := script -q $(LOG) $(SWITCH_CMD)
else
  SCRIPT_CMD := script -q --return -c "$(SWITCH_CMD)" $(LOG)
endif

check:
	@nix flake check --all-systems 2>&1 | tee $(LOG); EXIT_CODE=$${PIPESTATUS[0]}; \
	if [ $$EXIT_CODE -ne 0 ]; then \
		echo ""; \
		echo "========================================"; \
		echo " Check failed"; \
		echo "========================================"; \
		echo ""; \
		col -b < $(LOG) | claude --output-format text -p \
			"The Nix flake check failed with the following output. Diagnose the root cause and explain what went wrong. Respond with plain text only — do not attempt to edit or create files." \
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

switch:
	@$(SCRIPT_CMD); EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -ne 0 ]; then \
		echo ""; \
		echo "========================================"; \
		echo " Build failed"; \
		echo "========================================"; \
		echo ""; \
		col -b < $(LOG) | claude --output-format text -p \
			"The Nix build failed with the following output. Diagnose the root cause and explain what went wrong. Respond with plain text only — do not attempt to edit or create files." \
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
