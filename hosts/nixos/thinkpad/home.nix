{
  self,
  inputs,
  pkgs,
  ...
}:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    "${self}/modules/home"
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  dev.enable = true;

  # ============================================================================
  # SERVICES
  # ============================================================================
  services.flatpak = {
    packages = [ "app.zen_browser.zen" ];
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

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
  # programs.lutris.enable = true;

  home = {
    stateVersion = "25.05";

    packages = with pkgs; [
      # local apps
      obs-studio
      protonup-qt
      wine
      wayvnc
      # freecad # currently broken upstream

      # unity
      p7zip # unity-hub doesn't ship with 7z (03.01.26), so we need to include it here
      dotnet-sdk
      vscode
      unityhub

      # project dependencies
      stripe-cli
      redis

      prismlauncher
      python3
      supabase-cli
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
