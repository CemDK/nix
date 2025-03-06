{ pkgs, user, home, ... }:

{
  imports = [ ../../modules/home-manager/default.nix ];

  # TODO: re-evaluate if these are necessary
  # systemd.user.startServices = "sd-switch";
  # WSL-specific settings
  # home.sessionVariables = {
  #   DISPLAY = "$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0";
  #   LIBGL_ALWAYS_INDIRECT = "1";
  # };

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
