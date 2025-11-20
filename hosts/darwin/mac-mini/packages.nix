{ pkgs, ... }: {

  # ============================================================================
  # FONTS
  # ============================================================================
  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    aerospace
    claude-code
    # anki # borken atm
    hidden-bar
    mkalias
    nodejs
    obsidian
    raycast
    stats

  ];

  users.users.cemdk.packages = with pkgs; [
    wakatime-cli
    nix-search-tv
    fastfetch
    # Add user packages here
  ];

  services.aerospace = {
    enable = true;
    package = pkgs.aerospace;
    settings = builtins.fromTOML
      (builtins.readFile ../../../dotfiles/aerospace/aerospace.toml);
  };

  # ============================================================================
  # OTHER CONFIGURATIONS
  # ============================================================================
  # TODO: not working
  # This will add better display, hidden-bar, etc. shortucts into /Applications/Nix Apps/
  # system.activationScripts.applications.text = let
  #   env = pkgs.buildEnv {
  #     name = "system-applications";
  #     paths = config.environment.systemPackages;
  #     pathsToLink = "/Applications";
  #   };
  # in pkgs.lib.mkForce ''
  #   # Set up applications.
  #   echo "setting up /Applications..." >&2
  #   rm -rf /Applications/Nix\ Apps
  #   mkdir -p /Applications/Nix\ Apps
  #   find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  #   while read -r src; do
  #       app_name=$(basename "$src")
  #       echo "copying $src" >&2
  #       ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
  #   done
  # '';

  # system.activationScripts.applications.text = ''
  #   set -e
  #   echo >&2 "Switching wallpapers..."
  #   /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file
  #   \"${
  #     /Users/cemdk/.config/wallpapers/autumn-season-leafs-plant-scene-generative-ai.jpg
  #   }\""
  # '';
}
