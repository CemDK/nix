{ ... }:
{
  programs.walker = {
    enable = true;
    runAsService = true;
    themes = {
      "teal" = {
        style = builtins.readFile ./style.css;
        layouts = {
          "layout" = builtins.readFile ./layout.xml;
        };
      };
    };
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
  };
}
