{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alt-tab-macos
    bat
    gh
    go
    htop
    hidden-bar
    jq
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
    vim
    yabai
    yazi
  ];

}
