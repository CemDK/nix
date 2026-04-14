{ pkgs, ... }:
{

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-custom ];
  };
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    libva-utils
    mangohud
    vulkan-loader
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
