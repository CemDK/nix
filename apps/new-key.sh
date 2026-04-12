# Onboard a machine's age key for sops decryption
# Invoked via: nix run .#new-key

trap 'echo ""; exit 0' INT

FLAKE_DIR="$(pwd)"
SOPS_YAML="$FLAKE_DIR/.sops.yaml"
PURPLE="#845DF9"

header() { gum style --foreground "$PURPLE" --bold "$1"; }
success() { gum style --foreground 46 "✓ $1"; }
error() { gum style --foreground 196 "$1"; exit 1; }

main() {
    clear
    header "Onboard SOPS Age Key"
    echo ""

    if [[ ! -f "$SOPS_YAML" ]]; then
        error ".sops.yaml not found in $FLAKE_DIR"
    fi

    # Show current keys for context
    gum style --foreground 208 "Current keys in .sops.yaml:"
    grep '^ *- &' "$SOPS_YAML" | sed 's/^ */  /' || echo "  (none found)"
    echo ""

    # Step 1: Get key name
    NAME=$(gum input --placeholder "e.g. my_server" --prompt "Key name (for .sops.yaml): ")
    [[ -z "$NAME" ]] && error "Key name cannot be empty."

    if grep -q "&$NAME " "$SOPS_YAML"; then
        error "Key '$NAME' already exists in .sops.yaml"
    fi

    # Step 2: Get the age key
    SOURCE=$(gum choose "Remote (SSH host key)" "Local (this machine)" --header "Where is the SSH host key?")

    if [[ "$SOURCE" == "Remote (SSH host key)" ]]; then
        HOST=$(gum input --placeholder "e.g. 192.168.1.100" --prompt "SSH host: ")
        [[ -z "$HOST" ]] && error "SSH host cannot be empty."

        echo ""
        gum spin --spinner dot --title "Fetching SSH host key from $HOST..." -- sleep 1

        HOST_KEY=$(ssh-keyscan -t ed25519 "$HOST" 2>/dev/null || true)
        if [[ -z "$HOST_KEY" ]]; then
            error "Could not fetch SSH host key from $HOST. Is the host reachable and running SSH?"
        fi

        AGE_KEY=$(echo "$HOST_KEY" | ssh-to-age || true)
    else
        if [[ ! -f /etc/ssh/ssh_host_ed25519_key.pub ]]; then
            error "No ed25519 host key found at /etc/ssh/ssh_host_ed25519_key.pub"
        fi
        AGE_KEY=$(ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub || true)
    fi

    if [[ -z "$AGE_KEY" ]]; then
        error "Failed to derive age key. Is an ed25519 host key available?"
    fi

    echo ""
    success "Derived age key"
    echo ""

    gum style --border normal --padding "1 2" --border-foreground "$PURPLE" \
        "Name: $NAME" \
        "Key:  $AGE_KEY"

    echo ""

    # Step 3: Add to .sops.yaml keys list
    add_key "$NAME" "$AGE_KEY"

    # Step 4: Add to global secrets
    add_to_global "$NAME"

    # Step 5: Optionally create a new creation rule
    echo ""
    if gum confirm "Create a new creation_rule for this machine?"; then
        add_creation_rule "$NAME"
    fi

    # Step 6: Rekey
    echo ""
    if gum confirm "Rekey all secret files now?"; then
        echo ""
        find "$FLAKE_DIR/secrets" -name "*.yaml" -print0 | xargs -0 -I{} sops updatekeys --yes {}
        success "All secret files rekeyed"
    else
        echo ""
        gum style --foreground 208 "Remember to run: make rekey"
    fi

    echo ""
    success "Done! Key '$NAME' has been onboarded."
}

# ===========================================================================
# .sops.yaml EDITING
# ===========================================================================
add_key() {
    local name="$1" age_key="$2"
    local marker="  # <<< ADD KEY >>>"

    if ! grep -qF "$marker" "$SOPS_YAML"; then
        error "Marker '$marker' not found in .sops.yaml"
    fi

    awk -v entry="  - &$name $age_key" -v marker="$marker" \
        '{if (index($0, marker)) print entry; print}' \
        "$SOPS_YAML" > "$SOPS_YAML.tmp" && mv "$SOPS_YAML.tmp" "$SOPS_YAML"
    success "Added &$name to keys list"
}

add_to_global() {
    local name="$1"
    local marker="          # <<< ADD GLOBAL KEY >>>"

    if ! grep -qF "$marker" "$SOPS_YAML"; then
        error "Marker '$marker' not found in .sops.yaml"
    fi

    awk -v entry="          - *$name" -v marker="$marker" \
        '{if (index($0, marker)) print entry; print}' \
        "$SOPS_YAML" > "$SOPS_YAML.tmp" && mv "$SOPS_YAML.tmp" "$SOPS_YAML"
    success "Added *$name to global secrets"
}

add_creation_rule() {
    local name="$1"
    local marker="  # <<< ADD CREATION RULE >>>"

    if ! grep -qF "$marker" "$SOPS_YAML"; then
        error "Marker '$marker' not found in .sops.yaml"
    fi

    PATH_REGEX=$(gum input \
        --placeholder "e.g. secrets/myhost/.*\.(yaml|json|env|ini)$" \
        --prompt "path_regex: " \
        --value "secrets/$name/.*\.(yaml|json|env|ini)\$")
    [[ -z "$PATH_REGEX" ]] && error "path_regex cannot be empty."

    # Use awk instead of sed - the path_regex contains | which breaks sed delimiters
    local rule_block
    rule_block=$(printf '  - path_regex: %s\n    key_groups:\n      - age:\n          - *cem_ryzen\n          - *%s\n' "$PATH_REGEX" "$name")

    awk -v block="$rule_block" -v marker="$marker" \
        '{if (index($0, marker)) print block; print}' \
        "$SOPS_YAML" > "$SOPS_YAML.tmp" && mv "$SOPS_YAML.tmp" "$SOPS_YAML"

    success "Added creation_rule for $PATH_REGEX"
}

main "$@"
