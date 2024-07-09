{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bat
    gh
    go
    htop
    neofetch
    obsidian
    raycast
    tmux
    vscode
    yazi
  ];

}
