{ pkgs, ... }: {

  imports = [
    ../../../modules/home
    ../../../modules/home/retroarch
    # ../../modules/home-manager/alacritty.nix
  ];

  home = {
    packages = with pkgs; [
      brightnessctl
      pavucontrol
      playerctl
      claude-code
      localsend
      (callPackage ../../../modules/home/zen-browser { })
      obs-studio
    ];

    file = { };
  };
}

