{ lib, pkgs, ... }:
let
  config = {
    theme = "teal";
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
in
{
  services.elephant.enable = true;

  home.packages = [ pkgs.walker ];

  xdg.configFile = {
    "walker/config.toml".source = (pkgs.formats.toml { }).generate "walker-config.toml" config;
    "walker/themes/teal/style.css".source = ./style.css;
    "walker/themes/teal/layout.xml".source = ./layout.xml;
  };

  # Runs walker as a service for faster launch times.
  systemd.user.services.walker = {
    Unit = {
      Description = "Walker - Application Runner";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      After = [
        "graphical-session.target"
        "elephant.service"
      ];
      Requires = [ "elephant.service" ];
      PartOf = [ "graphical-session.target" ];
      X-Restart-Triggers = [ (builtins.hashString "sha256" (builtins.toJSON config)) ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.walker} --gapplication-service";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
