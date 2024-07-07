{ pkgs, ... }: {
  programs.neovim.enable = true;
  programs.neovim.coc.enable = true;
  programs.neovim.extraConfig = ''
    set number
  '';
}
