{
  programs.tmux = {
    enable = true;
    clock24 = true;
    sensibleOnTop = false;

    extraConfig = builtins.readFile ./dotfiles/tmux/tmux.conf;

    # use TPM instead inside the tmux.conf
    # plugins = with pkgs;
    # [
    # {
    #   plugin = tmuxPlugins.net-speed;
    #   extraConfig = "";
    # }
    # {
    #   plugin = tmux-pomodoro-plus;
    #   extraConfig = "";
    # }
    # ];

  };

}
