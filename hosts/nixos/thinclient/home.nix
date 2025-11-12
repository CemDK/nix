{ pkgs, user, home, ... }: {

  imports = [
    ../../../modules/home
    # ../../modules/home-manager/alacritty.nix
    #
  ];

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = { };
  home.packages = with pkgs; [
    brightnessctl
    neovim
    pavucontrol
    playerctl
    (callPackage ../../../modules/home/zen-browser { })
    xdg-desktop-portal-gtk
    libva-utils
    vulkan-loader
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

