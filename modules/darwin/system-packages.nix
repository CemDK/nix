{ pkgs, config, ... }:

{
  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  environment.systemPackages = with pkgs; [
    bat
    gh
    htop
    hidden-bar
    jq
    mkalias
    neofetch
    nixfmt-classic
    nodejs_23
    obsidian
    raycast
    ripgrep
    rustup
    skhd
    stats
    tmux
    vim
    yabai
  ];

  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in pkgs.lib.mkForce ''
    # Set up applications.
    echo "setting up /Applications..." >&2
    rm -rf /Applications/Nix\ Apps
    mkdir -p /Applications/Nix\ Apps
    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
    while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
    done
  '';
}
