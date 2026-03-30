{
  pkgs,
  self,
  system,
  user,
  home,
  host,
  ...
}:
{

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
  environment.shells = [
    pkgs.bash
    pkgs.zsh
  ];

  # ============================================================================
  # KEYBOARD
  # ============================================================================
  # keyboard = {
  #   enableKeyMapping = true;
  #   # remapCapsLockToEscape = true;
  # };

  # Swap z and y, because I grew up with QWERTZ :)
  launchd.user.agents.remap-keys = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        ''
          {
            "UserKeyMapping":[
              {"HIDKeyboardModifierMappingSrc":0x70000001C,"HIDKeyboardModifierMappingDst":0x70000001D},
              {"HIDKeyboardModifierMappingSrc":0x70000001D,"HIDKeyboardModifierMappingDst":0x70000001C}
            ]
          }
        ''
      ];
      RunAtLoad = true;
    };
  };

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
      loginwindow.GuestEnabled = false;

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
        persistent-apps = [
          "/Applications/Zen.app"
          "${pkgs.alacritty}/Applications/Alacritty.app"
          "/Applications/Anki.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "/System/Applications/System Settings.app"
        ];
        persistent-others = [
          {
            folder = {
              path = "/Applications/";
              displayas = "folder";
            };
          }

          {
            folder = {
              path = "${home}/Downloads/";
              displayas = "folder";
            };
          }
        ];
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
        FXDefaultSearchScope = "SCcf"; # current folder
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowPathbar = true;
        ShowStatusBar = false;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
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
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleSpacesSwitchOnActivate = false;
        InitialKeyRepeat = 14;
        KeyRepeat = 2;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSWindowResizeTime = 0.0;
      };

      # ============================================================================
      # OTHER PREFERENCES
      # ============================================================================
      CustomUserPreferences = {
        "com.microsoft.VSCode" = {
          ApplePressAndHoldEnabled = false;
        };

        # TODO: check if this is contained to mouse options
        # or if this messs with trackpad options
        NSGlobalDomain."com.apple.mouse.linear" = true;
        NSGlobalDomain."com.apple.swipescrolldirection" = false;

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        # "com.apple.Safari" = {
        #   # Privacy: don’t send search queries to Apple
        #   UniversalSearchEnabled = false;
        #   SuppressSearchSuggestions = true;
        # };

        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
      };
    };
  };
}
