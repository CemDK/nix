{ pkgs, user, home, ... }: {

  imports = [
    ../../../modules/home
    ../../../modules/home/retroarch
    # ../../modules/home-manager/alacritty.nix
  ];

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = { };
  home.packages = with pkgs; [
    btop
    brightnessctl
    neovim
    pavucontrol
    playerctl
    claude-code
    localsend
    (callPackage ../../../modules/home/zen-browser { })
    obs-studio
  ];

  home.stateVersion = "25.05";

}

