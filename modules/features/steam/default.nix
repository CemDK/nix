{ config, host, pkgs, lib, ... }: {

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    libva-utils
    vulkan-loader
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
