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
    claude-code
    (callPackage ../../../modules/home/zen-browser { })
    steam
    obs-studio
  ];

  home.stateVersion = "25.05";

  programs.bash = {
    enable = true;
    shellAliases = { btw = "echo i use nix"; };
  };

}

