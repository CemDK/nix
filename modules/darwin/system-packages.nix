{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    go
    htop
    gh
    neofetch
    tmux
    yazi
    obsidian
    vscode
  ];
}
