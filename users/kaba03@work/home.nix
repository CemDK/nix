{ pkgs, user, home, ... }:

{
  imports =
    [ ../../modules/home-manager ../../modules/home-manager/alacritty.nix ];

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

  home.packages = with pkgs; [
    cloudfoundry-cli
    gotools
    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    k9s
    kubernetes-helm
    kubectl
    kubevela

    alt-tab-macos
    go
    opentofu
    podman
    podman-desktop
    terragrunt
  ];
}
