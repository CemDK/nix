{
  self,
  pkgs,
  user,
  ...
}:
{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    "${self}/hosts/common.nix"
    "${self}/hosts/nixos/common.nix"
  ];

  # ============================================================================
  # USER MANAGEMENT
  # ============================================================================
  users.users.${user}.extraGroups = [ "docker" ];

  # ============================================================================
  # SERVICES
  # ============================================================================
  services.udisks2.enable = true;

  # ============================================================================
  # PACKAGES
  # ============================================================================
  programs = {
    git.enable = true;
    htop.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bat
    btop
    fd
    jq
    podman-compose
    podman-tui
    ripgrep
    tmux
    unzip
    vim
  ];
}
