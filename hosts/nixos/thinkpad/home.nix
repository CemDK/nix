{ self, pkgs, ... }:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    "${self}/modules/home"
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

  programs.walker = {
    enable = true;
    runAsService = true;
    config = {
      force_keyboard_focus = true;
      selection_wrap = true;
      hide_action_hints = true;
      hide_quick_activation = true;
      placeholders.default = {
        input = "Search...";
        list = "No Results";
      };
      keybinds = {
        next = [
          "Down"
          "ctrl j"
          "ctrl n"
        ];
        previous = [
          "Up"
          "ctrl k"
          "ctrl p"
        ];
      };
      providers = {
        max_results = 50;
        default = [
          "desktopapplications"
          "websearch"
        ];
        prefixes = [
          {
            prefix = "/";
            provider = "providerlist";
          }
          {
            prefix = ".";
            provider = "files";
          }
          {
            prefix = "=";
            provider = "calc";
          }
          {
            prefix = "$";
            provider = "clipboard";
          }
        ];
        actions.desktopapplications = [
          {
            action = "start";
            default = true;
            bind = "Return";
          }
          {
            action = "start:keep";
            label = "open+next";
            bind = "shift Return";
            after = "KeepOpen";
          }
          {
            action = "new_instance";
            label = "new instance";
            bind = "ctrl Return";
          }
          {
            action = "new_instance:keep";
            label = "new+next";
            bind = "ctrl alt Return";
            after = "KeepOpen";
          }
          {
            action = "pin";
            unset = true;
          }
          {
            action = "unpin";
            unset = true;
          }
          {
            action = "pinup";
            unset = true;
          }
          {
            action = "pindown";
            unset = true;
          }
        ];
      };
    };
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================
  programs.lutris.enable = true;

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
      claude-code
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
