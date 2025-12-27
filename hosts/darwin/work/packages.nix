{ pkgs, ... }: {

  # ============================================================================
  # FONTS
  # ============================================================================
  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  # this installs into /nix/store/...
  environment.systemPackages = with pkgs; [
    aerospace
    hidden-bar
    mkalias
    nodejs
    raycast
    stats
  ];

  # Add user packages here
  users.users.cemdk.packages = with pkgs; [
    fastfetch
    nix-search-tv
    wakatime-cli

    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    cloudfoundry-cli
    gotools
    k9s
    kubectl
    kubernetes-helm
    kubevela

    minikube
    postman
    yarn

    go
    opentofu
    podman
    podman-desktop
    terragrunt
  ];

  services.aerospace = {
    enable = true;
    package = pkgs.aerospace;
    settings =
      fromTOML (builtins.readFile ../../../dotfiles/aerospace/aerospace.toml);
  };
}
