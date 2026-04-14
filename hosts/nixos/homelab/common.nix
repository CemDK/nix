{
  self,
  pkgs,
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
  users.users.cemdk.extraGroups = [ "docker" ];

  # ============================================================================
  # SERVICES
  # ============================================================================
  services.udisks2.enable = true;

  # ============================================================================
  # VIRTUALIZATION
  # ============================================================================
  virtualisation = {
    containers.enable = true;
    podman = {
      autoPrune.enable = true;
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      backend = "podman";
      containers = { };
    };
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================
  programs.git.enable = true;
  programs.htop.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
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
