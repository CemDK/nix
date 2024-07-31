{ pkgs, ... }:
let
  baseConfig = builtins.readFile ./dotfiles/vim/base.vim;
  fzfConfig = builtins.readFile ./dotfiles/vim/fzf.vim;
in
{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      colorizer
      fzf-vim
      fzfWrapper
      vim-fugitive
      vim-polyglot
      vim-sensible
      vim-terraform
    ];
    extraConfig = ''
      ${baseConfig}
      ${fzfConfig}
      set termguicolors
      colorscheme orange_and_teal
    '';
  };
}
