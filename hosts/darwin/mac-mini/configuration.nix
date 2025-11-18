{ pkgs, self, system, user, home, host, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    #
    ./packages.nix
    ./brew.nix
  ];

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nix.enable = false;
  #  nix = {
  #    settings = {
  #      experimental-features = [ "nix-command" "flakes" ];
  #      trusted-users = [ "@wheel" ];
  #    };
  #    gc = {
  #      automatic = true;
  #     interval = {
  #       Weekday = 0;
  #       Hour = 0;
  #       Minute = 0;
  #     };
  #      options = "--delete-older-than 30d";
  #    };
  # optimise.automatic = true;
  #  };

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;
  # services.nix-daemon.enable = true;

  # ============================================================================
  # USER MANAGEMENT
  # ============================================================================
  users.users.${user}.home = "${home}";

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.hostName = host;

  # ============================================================================
  # SECURITY
  # ============================================================================
  security.pam.services.sudo_local.touchIdAuth = true;

  # ============================================================================
  # ENVIRONMENT
  # ============================================================================
  environment.shells = [ pkgs.bash pkgs.zsh ];

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system = {
    primaryUser = user;
    stateVersion = 6;
    configurationRevision = self.rev or self.dirtyRev or null;

    startup.chime = false;

    defaults = {
      LaunchServices.LSQuarantine = false; # quarantine downloaded apps?

      # ============================================================================
      # DOCK
      # ============================================================================
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        expose-animation-duration = 0.2;
        launchanim = false;
        mouse-over-hilite-stack = true;
        mru-spaces = false;
        # orientation = "bottom";
        # TODO:
        # persistent-apps = {
        # [ "/Applications/Safari.app" "/System/Applications/Nix\ Apps/Alacritty.app" ]
        # };
        show-recents = false;
        # tilesize = 48;
      };

      # ============================================================================
      # FINDER
      # ============================================================================
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        CreateDesktop = false;
        FXEnableExtensionChangeWarning = false;
        FXDefaultSearchScope = "SCcf"; # current folder
        FXPreferredViewStyle = "Nlsv";
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowPathbar = true;
        ShowStatusBar = false;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        QuitMenuItem = true;
      };

      # ============================================================================
      # TRACKPAD
      # ============================================================================
      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
        TrackpadThreeFingerTapGesture = 2;
      };

      # ============================================================================
      # NSGLOBALDOMAIN
      # ============================================================================
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        # TODO: toggle this once my keyboard layout lives in nix-darwin
        # ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 2;
        NSWindowResizeTime = 0.0;
        AppleSpacesSwitchOnActivate = false;
      };

      # ============================================================================
      # KEYBOARD
      # ============================================================================
      # keyboard = {
      # enableKeyMapping = true;
      # remapCapsLockToEscape = true;
      # };

      # ============================================================================
      # OTHER PREFERENCES
      # ============================================================================
      CustomUserPreferences = {
        "com.microsoft.VSCode" = { ApplePressAndHoldEnabled = false; };
      };
    };
  };
}
