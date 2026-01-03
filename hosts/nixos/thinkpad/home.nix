{ pkgs, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    # Import custom modules
    ../../../modules/home
    #../../../modules/home/retroarch
  ];

  # ============================================================================
  # SERVICES
  # ============================================================================
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

      # unity
      p7zip # unity-hub doesn't ship with 7z (03.01.26), so we need to include it here
      unityhub

      # project dependencies
      stripe-cli
      redis
    ];

    file = { };
    pointerCursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      size = 36;
      gtk.enable = true;
      x11.enable = true;
    };
  };

}

