{ pkgs, ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden --follow --glob '!.git/*'";
    defaultOptions = [
      "--layout=reverse"
      "--preview-window=up,70%"
      "--bind 'ctrl-/:toggle-preview'"
    ];
      #"--preview 'bat --style=numbers --color=always --line-range :500 {}'"

    colors = {
      "fg"="#93a1a1";
      "hl"="#268bd2";
      "fg+"="#c5c8c6";
      "bg+"="#005F60";
      "hl+"="#8ec07c";
      "info"="#2aa198";
      "prompt"="#f78104";
      "pointer"="#f78104";
      "marker"="#f78104";
      "spinner"="#f78104";
      "header"="#268bd2";
      "border"="#005F60";
    };
  };
}
