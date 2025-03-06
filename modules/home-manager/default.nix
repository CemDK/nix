{ config, lib, pkgs, ... }:

{
  # Common across all machines and users
  imports = [ ./eza.nix ./fzf.nix ./vim.nix ./zsh.nix ];

  home.stateVersion = "21.11";

  home.packages = with pkgs; [
    bat
    curl
    fd
    fzf
    gh
    git
    htop
    jq
    neofetch
    nixfmt-classic
    ripgrep
    rustup
    tmux
    wget
    vim
    zsh
  ];

  programs = {
    # home-manager.enable = true;
    git.enable = true;
  };
}
