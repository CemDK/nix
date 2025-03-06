{ pkgs, user, home, ... }:

{
  imports = [ ../../modules/home-manager/default.nix ];

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = {
    ".config/nvim" = {
      source = ../../modules/home-manager/dotfiles/nvim;
      recursive = true;
    };

    ".config/tmux/tmux.conf".source =
      ../../modules/home-manager/dotfiles/tmux/tmux.conf;

    ".config/.p10k-rainbow.zsh".source =
      ../../modules/home-manager/dotfiles/.p10k-rainbow.zsh;
  };

  home.packages = with pkgs; [ ];
}
