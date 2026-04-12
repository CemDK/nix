{ self, pkgs, ... }:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    "${self}/modules/home"
    "${self}/modules/home/retroarch"
  ];

  # ============================================================================
  # PACKAGES
  # ============================================================================
  home = {
    stateVersion = "25.05";

    packages = with pkgs; [
      # local apps
      # libva-utils
      # vulkan-loader
      # xdg-desktop-portal-gtk
      claude-code
    ];

    file = { };
  };
}
