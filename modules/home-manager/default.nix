{ config, lib, pkgs, ... }:

{
  # Common across all machines and users
  imports = [
    # ./git.nix
    ./zsh.nix
    ./eza.nix
    ./neovim.nix
  ];

  nixpkgs.config.allowUnfree = true;
  home.stateVersion = "21.11";

  home.packages = with pkgs; [
    bat
    curl
    fd
    fzf
    git
    htop
    jq
    neofetch
    nixfmt-classic
    ripgrep
    tmux
    wget
    zsh
  ];

  programs = {
    # home-manager.enable = true;
    git.enable = true;
  };
}
