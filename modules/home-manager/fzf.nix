{ pkgs, ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden --follow --glob '!.git/*'";
    defaultOptions = [
      "--layout=reverse"
      "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
      "--preview-window=up,70%"
      "--bind 'ctrl-/:toggle-preview'"
    ];
    colors = {
      "fg"="#93a1a1";
      "hl"="#268bd2";
      "fg+"="#c5c8c6";
      "bg+"="#005F60";
      "hl+"="#83a598";
      "info"="#2aa198";
      "prompt"="#fd5901";
      "pointer"="#fd5901";
      "marker"="#f78104";
      "spinner"="#f78104";
      "header"="#268bd2";
      "border"="#005F60";
    };
  };
}
