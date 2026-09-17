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
    sleep.computer = "never";
    sleep.harddisk = "never";
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
  launchd.daemons.mini-jobs.serviceConfig = {
    Label = "org.cemdk.mini-jobs";
    ProgramArguments = [ "/Users/cemdk/dev/personal/home-assistant/mini-jobs/run.sh" ];
    UserName = "cemdk";
    RunAtLoad = true;
    WorkingDirectory = "/Users/cemdk";
    EnvironmentVariables.HOME = "/Users/cemdk";
    StandardOutPath = "/Users/cemdk/Library/Logs/mini-jobs.log";
    StandardErrorPath = "/Users/cemdk/Library/Logs/mini-jobs.log";
  };

  security.sudo.extraConfig = "cemdk ALL=(root) NOPASSWD: /sbin/shutdown -h now";

  # --- Screen Sharing (video + your keyboard/mouse) -------------------------
  system.activationScripts.postActivation.text = ''
    echo "enabling Screen Sharing..." >&2
    launchctl enable system/com.apple.screensharing
    launchctl bootstrap system \
      /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true
  '';
}
