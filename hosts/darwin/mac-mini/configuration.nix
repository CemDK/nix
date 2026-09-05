{ config, self, ... }:
let
  inherit (config.common) user;
in
{
  imports = [
    "${self}/hosts/darwin/common.nix"
    ./packages.nix
    ./brew.nix
  ];

  # ============================================================================
  # HOST IDENTITY
  # ============================================================================
  common = {
    user = "cemdk";
    home = "/Users/cemdk";
  };
  nixpkgs.hostPlatform = "aarch64-darwin";

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = 6;
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.loginwindow.autoLoginUser = user;

  power = {
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
    sleep.computer = "never";
    sleep.harddisk = "never";
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    tailscale.enable = true;
  };

  # --- Screen Sharing (video + your keyboard/mouse) -------------------------
  system.activationScripts.postActivation.text = ''
    echo "enabling Screen Sharing..." >&2
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system \
      /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';
}
