{ pkgs, ... }: {

  imports = [
    ../../../modules/home
    ../../../modules/home/retroarch
    #
  ];

  home.file = { };
  home.packages = with pkgs; [
    libva-utils
    vulkan-loader
    xdg-desktop-portal-gtk
  ];

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    shellAliases = { btw = "echo i use nix"; };
  };
}

