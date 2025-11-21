{ pkgs, ... }: {

  imports = [
    ../../../modules/home
    ../../../modules/home/retroarch
    #
  ];

  home = {
    packages = with pkgs; [
      # local apps
      claude-code
      localsend
      obs-studio
    ];

    file = { };
  };

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nemo-with-extensions}/bin/nemo";
      };
    };
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

    # lutris
    protonup-qt
    wine
    wayvnc
  ];

  programs.lutris.enable = true;

  home.stateVersion = "25.05";

}

