{ pkgs, config, ... }:

{
  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # Add any applications that you want on all apple devices here.
  # User-specific applications should be added to the user config in /users/$user/home.nix 
  environment.systemPackages = with pkgs; [
    hidden-bar
    mkalias
    nodejs
    obsidian
    raycast
    stats
    neovim
    betterdisplay
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
