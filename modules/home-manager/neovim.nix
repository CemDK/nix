{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Install plugin dependencies
    extraPackages = with pkgs; [
      # LSP servers
      rust-analyzer

      # Tools
      ripgrep
      fd
      fzf

      # For treesitter
      gcc
      nodejs
    ];
  };
}
