{ pkgs, ... }:
let
  baseConfig = builtins.readFile ./vim/base.vim;
  fzfConfig = builtins.readFile ./vim/fzf.vim;
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
    '';
  };
}
