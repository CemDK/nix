{ pkgs, ... }: {

  imports = [
    ../../../modules/home
    ../../../modules/home/retroarch
    #
  ];

  home = {
    packages = with pkgs; [
      # local apps
      obs-studio

      protonup-qt
      wine
      wayvnc
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

  programs.lutris.enable = true;

  home.stateVersion = "25.05";

}

