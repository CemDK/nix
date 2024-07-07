 { pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./eza.nix
    ./vim.nix
    ./zsh.nix
  ];

  home.stateVersion = "24.05";
  
  home.packages = with pkgs; [
    less
  ];

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "nvim";
  };

} 
