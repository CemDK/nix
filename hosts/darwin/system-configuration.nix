{ pkgs, system, user, home, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [ ./system-packages.nix ./system-defaults.nix ];

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;
  # services.nix-daemon.enable = true;

  # ============================================================================
  # USER MANAGEMENT
  # ============================================================================
  users.users.${user}.home = "${home}";

  # ============================================================================
  # SECURITY
  # ============================================================================
  security.pam.services.sudo_local.touchIdAuth = true;

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;

  # ============================================================================
  # ENVIRONMENT
  # ============================================================================
  environment.shells = [ pkgs.bash pkgs.zsh ];

}
