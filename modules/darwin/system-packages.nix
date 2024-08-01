{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alt-tab-macos
    bat
    gh
    go
    htop
    hidden-bar
    neofetch
    obsidian
    opentofu
    raycast
    rectangle
    ripgrep
    rustup
    skhd
    stats
    terragrunt
    tmux
    tree-sitter
    vscode
    yabai
    yazi
  ];

}
