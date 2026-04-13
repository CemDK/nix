# Initialize this machine for sops secret decryption
# Invoked via: nix run .#init-sops
#
# Ensures the local machine has:
#   1. An SSH ed25519 keypair at ~/.ssh/id_ed25519
#   2. An age private key at ~/.config/sops/age/keys.txt (derived from the SSH key)
#
# The age public key is displayed so it can be added to .sops.yaml

trap 'echo ""; exit 0' INT

PURPLE="#845DF9"

header() { gum style --foreground "$PURPLE" --bold "$1"; }
success() { gum style --foreground 46 "✓ $1"; }
warn() { gum style --foreground 208 "$1"; }
error() { gum style --foreground 196 "$1"; exit 1; }

SSH_KEY="$HOME/.ssh/id_ed25519"
AGE_DIR="$HOME/.config/sops/age"
AGE_KEY="$AGE_DIR/keys.txt"

main() {
    clear
    header "Initialize SOPS Keys"
    echo ""

    ensure_ssh_key
    derive_age_key

    echo ""
    AGE_PUB=$(ssh-to-age < "$SSH_KEY.pub")
    success "Machine is ready for sops decryption"
    echo ""

    gum style --border normal --padding "1 2" --border-foreground "$PURPLE" \
        "SSH key:  $SSH_KEY" \
        "Age key:  $AGE_KEY" \
        "Age pub:  $AGE_PUB"

    echo ""
    header "Next steps"
    echo "  1. Add the age public key to .sops.yaml (or use: nix run .#new-key)"
    echo "  2. Rekey secrets: make rekey"
}

ensure_ssh_key() {
    if [[ -f "$SSH_KEY" ]]; then
        success "SSH key exists: $SSH_KEY"
        # Verify it's ed25519
        if ! ssh-keygen -l -f "$SSH_KEY" | grep -q ED25519; then
            error "$SSH_KEY exists but is not ed25519. Cannot derive age key."
        fi
        return
    fi

    echo ""
    warn "No SSH ed25519 key found at $SSH_KEY"
    echo ""

    if ! gum confirm "Generate a new SSH ed25519 keypair?"; then
        error "Cannot proceed without an ed25519 SSH key."
    fi

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    echo ""
    ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$(whoami)@$(hostname)"
    echo ""
    success "Generated SSH key: $SSH_KEY"
}

derive_age_key() {
    if [[ -f "$AGE_KEY" ]]; then
        # Check if existing age key matches the SSH key
        EXISTING_PUB=$(age-keygen -y "$AGE_KEY" 2>/dev/null || true)
        EXPECTED_PUB=$(ssh-to-age < "$SSH_KEY.pub" 2>/dev/null || true)

        if [[ "$EXISTING_PUB" == "$EXPECTED_PUB" ]]; then
            success "Age key exists and matches SSH key: $AGE_KEY"
            return
        fi

        echo ""
        warn "Age key exists but does not match SSH key"
        warn "  Age key pub:      $EXISTING_PUB"
        warn "  SSH-derived pub:  $EXPECTED_PUB"
        echo ""

        if ! gum confirm "Overwrite age key with SSH-derived key?"; then
            warn "Keeping existing age key"
            return
        fi
    fi

    mkdir -p "$AGE_DIR"
    chmod 700 "$AGE_DIR"

    ssh-to-age -private-key -i "$SSH_KEY" > "$AGE_KEY"
    chmod 600 "$AGE_KEY"
    success "Derived age key from SSH key: $AGE_KEY"
}

main "$@"
