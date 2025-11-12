{ pkgs, ... }: {

  programs.steam.enable = true;

  home.packages = with pkgs; [
    xdg-desktop-portal-gtk
    libva-utils
    vulkan-loader
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
