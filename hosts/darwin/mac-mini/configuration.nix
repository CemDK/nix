{ self, user, ... }:
{
  imports = [
    "${self}/hosts/darwin/common.nix"
    ./packages.nix
    ./brew.nix
  ];

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = 6;
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.swipescrolldirection" = false;
  system.defaults.loginwindow.autoLoginUser = user;
  system.defaults.loginwindow.GuestEnabled = false;

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

    openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
        KbdInteractiveAuthentication no
        AllowUsers cemdk
        MaxAuthTries 5
        LogLevel VERBOSE
      '';
    };
  };

  # --- Screen Sharing (video + your keyboard/mouse) -------------------------
  system.activationScripts.postActivation.text = ''
    echo "enabling Screen Sharing..." >&2
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system \
      /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';
}
