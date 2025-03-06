{ pkgs, config, home, lib, ... }:

{
  imports = [ ./alacritty.nix ./fzf.nix ./eza.nix ./vim.nix ./zsh.nix ];

  home.stateVersion = "24.05";

  home.packages = with pkgs; [ fd tree ];

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "nvim";
  };
}
