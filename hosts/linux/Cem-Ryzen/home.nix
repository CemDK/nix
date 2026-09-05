{
  config,
  self,
  ...
}:
{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    "${self}/hosts/common.nix"
    ./packages.nix
    "${self}/modules/home"
  ];

  # ============================================================================
  # HOST IDENTITY
  # ============================================================================
  common = {
    user = "cem";
    home = "/home/cem";
  };

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
  news.display = "show";

  home = {
    username = config.common.user;
    homeDirectory = config.common.home;
    stateVersion = "25.11";
    file = { };
  };

  targets.genericLinux.enable = true;
}
