{ pkgs, user, home, ... }:

{
  imports = [ ../../modules/home-manager ];

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = {
    ".config/.p10k-rainbow.zsh".source =
      ../../modules/home-manager/dotfiles/.p10k-rainbow.zsh;
    ".config/tmux/tmux.conf".source =
      ../../modules/home-manager/dotfiles/tmux/tmux.conf;
  };

  home.packages = with pkgs; [ ];
}
