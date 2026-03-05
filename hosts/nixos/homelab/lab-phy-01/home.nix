{ config, pkgs, ... }:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    # Import custom modules
    # ../../../../modules/home
  ];

  # ============================================================================
  # HOME CONFIGURATION
  # ============================================================================
  home = {
    stateVersion = "25.05";

    packages = with pkgs; [
      # local apps
    ];

    file = { };
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # ============================================================================
  # EXTRA PROGRAMS
  # ============================================================================
  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
}
