{ pkgs, user, home, ... }:

{
  imports = [
    ../../modules/home-manager/default.nix
    ../../modules/home-manager/alacritty.nix
  ];

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = {
    ".config/tmux/tmux.conf".source =
      ../../modules/home-manager/dotfiles/tmux/tmux.conf;

    ".config/.p10k-rainbow.zsh".source =
      ../../modules/home-manager/dotfiles/.p10k-rainbow.zsh;
  };

  home.packages = with pkgs; [ ];
}
