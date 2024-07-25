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
    neovim
    obsidian
    opentofu
    raycast
    rectangle
    ripgrep
    # stats
    terragrunt
    tmux
    vscode
    yabai
    yazi
  ];

}
