{ self, ... }:
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

  power = {
    restartAfterPowerFailure = true;
    restartAfterFreeze = true;
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    tailscale.enable = true;
  };

  # ============================================================================
  # JOB RUNNER (home-assistant repo: mini-jobs/README.md)
  # ============================================================================
  common.sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGcdDBJwN+t+e9LecOeBaBAl5t2yBlBPXMOd+9vT3mml cem-server@omv mini-jobs starter"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMZ5JQyNp/x0HdUFnUhK8dW/9MNZFrKFLGVuUTTlbe2 cemdk@thinkpad"
  ];

  # --- Sleep/wake (pmset; systemsetup does not stick on Apple silicon) ------
  # --- Screen Sharing (video + your keyboard/mouse) -------------------------
  system.activationScripts.postActivation.text = ''
    echo "configuring sleep..." >&2
    pmset -a sleep 10 displaysleep 10 disksleep 0 womp 1 autorestart 1 powernap 0

    echo "enabling Screen Sharing..." >&2
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system \
      /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';
}
