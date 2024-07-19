{ ... }:

{
  imports = [
    ../../modules/home-manager
  ];

  # User-specific configurations
  home.username = "cem";

  # User-specific file
  home.file.".config/.p10k-rainbow.zsh".source = ../../modules/home-manager/dotfiles/.p10k-rainbow.zsh;
  home.file.".config/yabai/yabairc".source = ../../modules/home-manager/dotfiles/yabairc;

  # Any other user-specific settings
}
