{ pkgs, inputs, user, home, ... }: {

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
  home.packages = with pkgs; [ neovim pavucontrol playerctl ];

  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    shellAliases = { btw = "echo i use nix"; };
  };

}

