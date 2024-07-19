{ pkgs, ... }: {
  home.file.".config/alacritty/themes".source = ./alacritty/themes;

  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    import = ["~/.config/alacritty/themes/orange-and-teal.toml"];
    env = {
       TERM = "xterm-256color";
    };
    window = {
      padding.x = 10;
      padding.y = 10;

      decorations = "Buttonless";

      opacity = 0.75;
      blur = true;
      option_as_alt = "Both";
    };
    font = {
      normal.family = "MesloLGS Nerd Font Mono";
      size = 14;
    };
    #window.dimensions = {
      #lines = 80;
      #columns = 150;
    #};

  };
}
