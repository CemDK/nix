{ pkgs, user, home, ... }:

{
  imports = [
    ../../modules/home-manager
  ];

  # User-specific configurations
  home.username = user;
  home.homeDirectory = home;

  # User-specific files
  home.file.".config/.p10k-rainbow.zsh".source = ../../modules/home-manager/dotfiles/.p10k-rainbow.zsh;
  home.file.".config/yabai/yabairc".source = ../../modules/home-manager/dotfiles/yabairc;
  home.file.".config/tmux/tmux.conf".source = ../../modules/home-manager/dotfiles/tmux/tmux.conf;

  home.packages = with pkgs; [
    cloudfoundry-cli
    gotools
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    k9s
    kubernetes-helm
    kubectl
    kubevela
  ];
}
