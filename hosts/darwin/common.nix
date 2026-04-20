{
  pkgs,
  lib,
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
    "${self}/hosts/common.nix"
    "${self}/modules/features/stylix"
  ];

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nix.enable = true;

  nixpkgs.hostPlatform = system;

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

  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_ENV_HINTS = "1";
  };

  # ============================================================================
  # KEYBOARD
  # Declarative keyboard layout (US with z/y swapped for QWERTZ muscle memory)
  keylayout = {
    enable = true;
    name = "U.S. Custom";
    baseLayout = "us";
    swapKeys = {
      y = "z";
      z = "y";
    };
    optionOverrides = {
      a = {
        lower = "ä";
        upper = "Ä";
      };
      o = {
        lower = "ö";
        upper = "Ö";
      };
      u = {
        lower = "ü";
        upper = "Ü";
      };
      d = {
        lower = "ö";
        upper = "Ö";
      };
      f = {
        lower = "ü";
        upper = "Ü";
      };
    };
    inherit user;
    inherit home;
  };

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system = {
    primaryUser = user;
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

      WindowManager = {
        StandardHideWidgets = true;
      };

      controlcenter.BatteryShowPercentage = true;
      controlcenter.NowPlaying = true;

      # ============================================================================
      # OTHER PREFERENCES
      # ============================================================================
      CustomUserPreferences = {
        "com.microsoft.VSCode" = {
          ApplePressAndHoldEnabled = false;
        };

        # Natural Scroll (swipescrolldirection) messes up scrollwheel direction...
        # set it to false on non macbooks
        NSGlobalDomain."com.apple.mouse.linear" = true;
        NSGlobalDomain."com.apple.swipescrolldirection" = lib.mkDefault true;

        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };

        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "60".enabled = false; # Disable input source switching (Ctrl+Space) for zsh autosuggestion-accept
            "61".enabled = false; # Disable input source switching (Ctrl+Option+Space)
            "64".enabled = false; # Disable Spotlight search (Cmd+Space) for Raycast
          };
        };

        "com.raycast.macos" = {
          raycastGlobalHotkey = "Command-49"; # Cmd+Space
          raycastPreferredWindowMode = "compact";
          raycastShouldFollowSystemAppearance = true;
          showFavoritesInCompactMode = true;
        };
      };
    };
  };
}
