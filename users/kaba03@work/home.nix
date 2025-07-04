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

  home.file = { };

  home.packages = with pkgs; [
    cloudfoundry-cli
    gotools
    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    k9s
    kubernetes-helm
    kubectl
    kubevela

    yarn
    postman
    minikube

    alt-tab-macos
    go
    opentofu
    # podman
    # podman-desktop
    terragrunt
  ];
}
