# Scaffold a new host configuration
# Invoked via: nix run .#new-host

trap 'echo ""; exit 0' INT

FLAKE_DIR="$(pwd)"
PURPLE="#845DF9"

header() { gum style --foreground "$PURPLE" --bold "$1"; }
success() { gum style --foreground 46 "✓ $1"; }
error() { gum style --foreground 196 "$1"; exit 1; }

main() {
    clear
    header "New Host Configuration"
    echo ""

    PLATFORM=$(gum choose "nixos" "darwin" "linux" --header "Platform:")
    NAME=$(gum input --placeholder "e.g. thinkpad, mac-mini" --prompt "Hostname: ")
    [[ -z "$NAME" ]] && error "Hostname cannot be empty."
    USER=$(gum input --placeholder "e.g. cemdk" --prompt "Username: " --value "cemdk")
    [[ -z "$USER" ]] && error "Username cannot be empty."

    IS_HOMELAB="no"

    case "$PLATFORM" in
        nixos)
            SYSTEM=$(gum choose "x86_64-linux" "aarch64-linux" --header "Architecture:")
            IS_HOMELAB=$(gum choose "no" "yes" --header "Homelab host?")
            HOME_DIR="/home/$USER"

            if [[ "$IS_HOMELAB" == "yes" ]]; then
                HOST_DIR="$FLAKE_DIR/hosts/nixos/homelab/$NAME"
            else
                HOST_DIR="$FLAKE_DIR/hosts/nixos/$NAME"
            fi

            [[ -d "$HOST_DIR" ]] && error "Host directory already exists: $HOST_DIR"
            mkdir -p "$HOST_DIR"
            scaffold_nixos "$HOST_DIR" "$NAME" "$USER"
            flake_add_nixos "$NAME" "$SYSTEM" "$USER" "$HOME_DIR" "$IS_HOMELAB"
            ;;
        darwin)
            SYSTEM="aarch64-darwin"
            HOME_DIR="/Users/$USER"
            HOST_DIR="$FLAKE_DIR/hosts/darwin/$NAME"

            [[ -d "$HOST_DIR" ]] && error "Host directory already exists: $HOST_DIR"
            mkdir -p "$HOST_DIR"
            scaffold_darwin "$HOST_DIR" "$NAME"
            flake_add_darwin "$NAME" "$SYSTEM" "$USER" "$HOME_DIR"
            ;;
        linux)
            SYSTEM=$(gum choose "x86_64-linux" "aarch64-linux" --header "Architecture:")
            HOME_DIR="/home/$USER"
            HOST_DIR="$FLAKE_DIR/hosts/linux/$NAME"

            [[ -d "$HOST_DIR" ]] && error "Host directory already exists: $HOST_DIR"
            mkdir -p "$HOST_DIR"
            scaffold_linux "$HOST_DIR"
            flake_add_home "$NAME" "$SYSTEM" "$USER" "$HOME_DIR"
            ;;
    esac

    # Format generated files and the updated flake.nix
    echo ""
    gum spin --spinner dot --title "Formatting with nix fmt..." -- nix fmt

    echo ""
    success "Created $HOST_DIR/"
    echo ""

    gum style --border normal --padding "1 2" --border-foreground "$PURPLE" \
        "Host:     $NAME" \
        "Platform: $PLATFORM" \
        "System:   $SYSTEM" \
        "User:     $USER" \
        "Home:     $HOME_DIR"

    echo ""
    header "Next steps"
    echo "  1. Edit the generated files in $HOST_DIR/"
    if [[ "$PLATFORM" == "nixos" ]]; then
        echo "  2. Generate hardware config:"
        echo "     Local:   nixos-generate-config --show-hardware-config > $HOST_DIR/hardware-configuration.nix"
        echo "     Remote:  ssh root@<ip> nixos-generate-config --show-hardware-config > $HOST_DIR/hardware-configuration.nix"
        echo "  3. Run: make check"
    else
        echo "  2. Run: make check"
    fi
}

# ===========================================================================
# SCAFFOLDING
# ===========================================================================
scaffold_nixos() {
    local dir="$1" name="$2" user="$3"

    cat > "$dir/configuration.nix" << 'EOF'
{
  self,
  pkgs,
  lib,
  inputs,
  host,
  user,
  ...
}:
{
  imports = [
    "${self}/hosts/nixos/common.nix"
    ./hardware-configuration.nix
  ];

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  networking.hostName = host;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = lib.mkDefault "25.05";
}
EOF

    cat > "$dir/home.nix" << 'EOF'
{ self, ... }:
{
  imports = [
    "${self}/modules/home"
  ];

  home.stateVersion = "25.05";
}
EOF

    cat > "$dir/hardware-configuration.nix" << 'EOF'
# PLACEHOLDER - replace with real hardware config:
#   nixos-generate-config --show-hardware-config > hardware-configuration.nix
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [ ];
  boot.kernelModules = [ ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "umask=077" ];
  };
}
EOF

    success "Scaffolded NixOS config for $name"
}

scaffold_darwin() {
    local dir="$1" name="$2"

    cat > "$dir/configuration.nix" << 'EOF'
{ self, ... }:
{
  imports = [
    "${self}/hosts/darwin/common.nix"
    ./packages.nix
    ./brew.nix
  ];

  system.stateVersion = 6;
}
EOF

    cat > "$dir/home.nix" << 'EOF'
{ self, ... }:
{
  imports = [
    "${self}/modules/home"
  ];

  home.stateVersion = "25.05";
}
EOF

    cat > "$dir/packages.nix" << 'EOF'
{ pkgs, ... }:
{
  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  environment.systemPackages = with pkgs; [
  ];
}
EOF

    cat > "$dir/brew.nix" << 'EOF'
{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    brews = [ ];
    casks = [ ];
    masApps = { };
  };
}
EOF

    success "Scaffolded Darwin config for $name"
}

scaffold_linux() {
    local dir="$1"

    cat > "$dir/home.nix" << 'EOF'
{
  self,
  inputs,
  ...
}:
{
  imports = [
    "${self}/hosts/common.nix"
    "${self}/modules/home"
    ./packages.nix
  ];

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
  ];

  systemd.user.startServices = "sd-switch";

  home = {
    stateVersion = "25.05";
    file = { };
  };
}
EOF

    cat > "$dir/packages.nix" << 'EOF'
{ pkgs, ... }:
{
  home.packages = with pkgs; [
  ];
}
EOF

    success "Scaffolded Linux (home-manager) config"
}

# ===========================================================================
# FLAKE EDITING
# ===========================================================================
flake_add_nixos() {
    local name="$1" system="$2" user="$3" home="$4" homelab="$5"
    local flake="$FLAKE_DIR/flake.nix"

    if [[ "$homelab" == "yes" ]]; then
        local marker="# <<< ADD HOMELAB HOST >>>"
        local entry="        \"$name\" = mkNixOSConfig { system = \"$system\"; user = \"$user\"; host = \"$name\"; home = \"$home\"; isHomelab = true; };"
    else
        local marker="# <<< ADD NIXOS HOST >>>"
        local entry="        \"$name\" = mkNixOSConfig { system = \"$system\"; user = \"$user\"; host = \"$name\"; home = \"$home\"; };"
    fi

    if ! grep -q "$marker" "$flake"; then
        error "Marker '$marker' not found in flake.nix"
    fi

    awk -v entry="$entry" -v marker="$marker" \
        '{if (index($0, marker)) print entry; print}' \
        "$flake" > "$flake.tmp" && mv "$flake.tmp" "$flake"
    success "Added $name to flake.nix nixosConfigurations"
}

flake_add_darwin() {
    local name="$1" system="$2" user="$3" home="$4"
    local flake="$FLAKE_DIR/flake.nix"
    local marker="# <<< ADD DARWIN HOST >>>"
    local entry="        \"$name\" = mkDarwinConfig { system = \"$system\"; user = \"$user\"; host = \"$name\"; home = \"$home\"; };"

    if ! grep -q "$marker" "$flake"; then
        error "Marker '$marker' not found in flake.nix"
    fi

    awk -v entry="$entry" -v marker="$marker" \
        '{if (index($0, marker)) print entry; print}' \
        "$flake" > "$flake.tmp" && mv "$flake.tmp" "$flake"
    success "Added $name to flake.nix darwinConfigurations"
}

flake_add_home() {
    local name="$1" system="$2" user="$3" home="$4"
    local flake="$FLAKE_DIR/flake.nix"
    local marker="# <<< ADD HOME HOST >>>"
    local entry="        \"$name\" = mkHomeConfig { system = \"$system\"; user = \"$user\"; host = \"$name\"; home = \"$home\"; };"

    if ! grep -q "$marker" "$flake"; then
        error "Marker '$marker' not found in flake.nix"
    fi

    awk -v entry="$entry" -v marker="$marker" \
        '{if (index($0, marker)) print entry; print}' \
        "$flake" > "$flake.tmp" && mv "$flake.tmp" "$flake"
    success "Added $name to flake.nix homeConfigurations"
}

main "$@"
