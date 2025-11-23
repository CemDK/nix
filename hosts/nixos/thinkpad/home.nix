{ pkgs, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    # Import custom modules
    ../../../modules/home
    ../../../modules/home/retroarch
  ];

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

