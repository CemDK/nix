 { pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./fzf.nix
    ./eza.nix
    ./vim.nix
    ./zsh.nix
  ];

  home.stateVersion = "24.05";
  
  home.packages = with pkgs; [
    fd
    less
    tree
  ];

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "nvim";
  };

} 
