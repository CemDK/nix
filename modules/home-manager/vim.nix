{ pkgs, ... }: {
  programs.vim = {
    enable = true;
    extraConfig = ''
      set autoindent
      set expandtab
      set number
      set shiftwidth=4
      set smartindent
      set softtabstop=4
      set tabstop=4
      set cursorline
      set cursorlineopt=number
    '';
    plugins = [pkgs.vimPlugins.colorizer];
  };
} 
