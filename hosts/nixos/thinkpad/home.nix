{ pkgs, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    # Import custom modules
    ../../../modules/home
    ../../../modules/home/retroarch
  ];

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nemo-with-extensions}/bin/nemo";
      };
    };
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================
  programs.lutris.enable = true;

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

}

