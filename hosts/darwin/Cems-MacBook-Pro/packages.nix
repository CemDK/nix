{
  pkgs,
  user,
  ...
}:
{

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
  # This installs into $HOME/.nix-profile
  users.users.${user}.packages = with pkgs; [
    wakatime-cli
    # (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    # cloudfoundry-cli
    # gotools
    # k9s
    # kubectl
    # kubernetes-helm
    # kubevela
    #
    # minikube
    # postman
    # yarn
    #
    # go
    # opentofu
    # podman
    # podman-desktop
    # terragrunt
    nix-search-tv
    fastfetch
    opencode
  ];

  # Add home-manager managed packages here
  # This installs into $HOME/.nix-profile
  # home.packages = with pkgs; [
  #   # bat
  # ];

  services.aerospace = {
    enable = true;
    package = pkgs.aerospace;
    settings = fromTOML (builtins.readFile ../../../dotfiles/aerospace/aerospace.toml);
  };

  # ============================================================================
  # OTHER CONFIGURATIONS
  # ============================================================================

  # system.activationScripts.applications.text = ''
  #   set -e
  #   echo >&2 "Switching wallpapers..."
  #   /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file
  #   \"${
  #     /Users/cemdk/.config/wallpapers/autumn-season-leafs-plant-scene-generative-ai.jpg
  #   }\""
  # '';

}
