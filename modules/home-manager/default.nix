{ config, pkgs, ... }:

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
    lua
    neofetch
    nodejs_23
    ripgrep
    rustup
    tmux
    typescript
    unzip
    wget
    vim
    zsh

    # for nvim
    nixd
    nodePackages.prettier
    tree-sitter
    nixfmt-classic
    # lazygit
    # eslint
    # eslint_d
    # lua-language-server
    # nodePackages.vscode-json-languageserver
    # tailwindcss-language-server
    # typescript-language-server
  ];

  home.file = {
    ".local/scripts/ready-tmux".source =
      ../../modules/home-manager/scripts/ready-tmux;

    ".local/scripts/tmux-sessionizer".source =
      ../../modules/home-manager/scripts/tmux-sessionizer;
  };

  programs = {
    # home-manager.enable = true;
    git.enable = true;
  };
}
