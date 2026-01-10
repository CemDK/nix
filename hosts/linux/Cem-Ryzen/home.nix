{
  lib,
  inputs,
  ...
}:
{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    # Import custom modules
    ../../../modules/home
    ./packages.nix
  ];

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nixpkgs.config.allowUnfree = true;
  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    # "home-manager=${inputs.home-manager}"
  ];

  # ============================================================================
  # SERVICES
  # ============================================================================
  # “When I run home-manager switch, ask systemd --user to
  # start/stop/restart services using systemd-native logic,
  # instead of manually killing and restarting them.”
  systemd.user.startServices = "sd-switch";

  # ============================================================================
  # HOME SETTINGS
  # ============================================================================
  home = {
    stateVersion = lib.mkForce "21.11";
    file = { };
  };
}
