{ config, pkgs, ... }: {
  home.username = "cemdk";
  home.homeDirectory = "/home/cemdk";
  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    shellAliases = { btw = "echo i use nix"; };
  };

}

