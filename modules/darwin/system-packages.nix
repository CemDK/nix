{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    gh
    go
    htop
    neofetch
    obsidian
    tmux
    vscode
    yazi
  ];

}
