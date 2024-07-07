{ pkgs, ... }: {
  programs.eza = {
    enable = true;
    git = true;
    icons = false;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
}
