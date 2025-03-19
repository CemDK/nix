{
  system.startup.chime = false;
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      expose-animation-duration = 0.2;
      launchanim = false;
      mru-spaces = false;
      # TODO
      # persistent-apps = {
      # [ "/Applications/Safari.app" "/System/Applications/Utilities/Terminal.app" ]
      # };
      show-recents = false;
    };

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

    trackpad = {
      TrackpadThreeFingerDrag = true;
      Clicking = true;
      TrackpadThreeFingerTapGesture = 2;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      InitialKeyRepeat = 14;
      KeyRepeat = 2;
      NSWindowResizeTime = 0.0;
    };

    CustomUserPreferences = {
      "com.microsoft.VSCode" = { ApplePressAndHoldEnabled = false; };
    };
  };
}
