{ pkgs, ... }:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [ ../wayland-desktop ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    hyprpaper # Wallpaper daemon
  ];
}
