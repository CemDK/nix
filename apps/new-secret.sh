# Create or edit a sops-encrypted secret file
# Invoked via: nix run .#new-secret

trap 'echo ""; exit 0' INT

FLAKE_DIR="$(pwd)"
SECRETS_DIR="$FLAKE_DIR/secrets"
PURPLE="#845DF9"

header() { gum style --foreground "$PURPLE" --bold "$1"; }
success() { gum style --foreground 46 "✓ $1"; }
error() { gum style --foreground 196 "$1"; exit 1; }

main() {
    clear
    header "SOPS Secret Management"
    echo ""

    if [[ ! -d "$SECRETS_DIR" ]]; then
        error "Secrets directory not found: $SECRETS_DIR"
    fi

    ACTION=$(gum choose "Edit existing secret" "Create new secret" --header "What would you like to do?")

    case "$ACTION" in
        "Edit existing secret") edit_secret ;;
        "Create new secret")    create_secret ;;
    esac
}

edit_secret() {
    # Find all yaml files under secrets/
    mapfile -t SECRET_FILES < <(find "$SECRETS_DIR" -name "*.yaml" -type f | sort)

    if [[ ${#SECRET_FILES[@]} -eq 0 ]]; then
        error "No secret files found in $SECRETS_DIR"
    fi

    # Build display list with relative paths
    local display_files=()
    for f in "${SECRET_FILES[@]}"; do
        display_files+=("${f#"$FLAKE_DIR/"}")
    done

    SELECTED=$(printf '%s\n' "${display_files[@]}" | gum choose --header "Select secret file to edit:")
    [[ -z "$SELECTED" ]] && exit 0

    echo ""
    header "Opening $SELECTED"
    sops "$FLAKE_DIR/$SELECTED"

    echo ""
    success "Done editing $SELECTED"
}

create_secret() {
    echo ""
    gum style --foreground 208 "Existing structure:"
    find "$SECRETS_DIR" -name "*.yaml" -type f | sed "s|$FLAKE_DIR/||" | sort
    echo ""

    FILENAME=$(gum input --placeholder "e.g. secrets/myhost/secrets.yaml" --prompt "Path (relative to flake): " --value "secrets/")
    [[ -z "$FILENAME" ]] && error "Filename cannot be empty."

    FULL_PATH="$FLAKE_DIR/$FILENAME"

    # Ensure parent directory exists
    mkdir -p "$(dirname "$FULL_PATH")"

    # Check .sops.yaml has a matching creation rule
    echo ""
    gum style --foreground 208 "Make sure .sops.yaml has a creation_rule matching: $FILENAME"
    echo ""

    if ! gum confirm "Continue creating $FILENAME?"; then
        exit 0
    fi

    if ! sops "$FULL_PATH"; then
        echo ""
        gum style --foreground 196 "sops failed. Most likely no creation_rule in .sops.yaml matches: $FILENAME"
        echo ""
        echo "  Add a rule to .sops.yaml, e.g.:"
        echo ""
        echo "    - path_regex: ${FILENAME%/*}/.*\\.(yaml|json|env|ini)\$"
        echo "      key_groups:"
        echo "        - age:"
        echo "            - *cem_ryzen"
        echo ""
        echo "  Then try again."
        exit 1
    fi

    echo ""
    success "Created $FILENAME"
}

main "$@"
