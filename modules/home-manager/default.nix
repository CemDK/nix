{ pkgs, config, ... }: {
  home.stateVersion = "24.05";
  home.username = "cem";
  home.packages = with pkgs; [
    less
  ];

  imports = [
    (import ./alacritty.nix {inherit pkgs config;})
    (import ./eza.nix {inherit pkgs config;})
    (import ./vim.nix {inherit pkgs config;})
    (import ./zsh.nix {inherit pkgs config;})
  ];

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "nvim";
  };


  home.file.".p10k-rainbow.zsh".source = ./.p10k-rainbow.zsh;
}
