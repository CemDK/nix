{
  homebrew = {
    enable = true;
    # caskArgs.no_quarantine = true;
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      # brew 6.0.9 deprecated the `--cleanup` switch: it now runs as a dry-run
      # that prints "Would uninstall ..." and EXITS 1 whenever cleanup is
      # pending, which aborts nix-darwin activation. And `cleanup = "uninstall"`
      # emits the `--force-cleanup` flag that brew 6.0 removed. Neither works,
      # so disable auto-cleanup. To prune manually: `brew bundle cleanup --force`.
      cleanup = "none";
    };
    global.autoUpdate = true;

    # CLI-TOOLS, LIBRARIES, ETC.
    brews = [
      # "bitwarden-cli"
      "direnv"
      "winetricks"
      "llama.cpp"
      # "ollama"
      # "tailscale"
      # "borders"
    ];

    # USER REPOSITORIES
    taps = [
      # "FelixKratz/formulae" #sketchybar
    ];

    # GUI APPLICATIONS
    casks = [
      "anki"
      "playonmac"
      "plex"
      "visual-studio-code"
      "vlc"
      "wine-stable"
      "whisky"
      "xquartz"
      # "neovide"
      # "adobe-creative-cloud"
      # "alacritty"
      # "alcove"
      # "audacity"
      # "audio-hijack"
      # "balenaetcher"
      # "bambu-studio"
      # "bentobox"
      "betterdisplay"
      "claude"
      "claude-code"
      # "cleanshot"
      # "clop"
      # "discord"
      # "displaylink"
      # "docker"
      # "easy-move-plus-resize"
      # "element"
      # "elgato-camera-hub"
      # "elgato-control-center"
      # "elgato-stream-deck"
      # "farrago"
      # "firefox"
      # "flameshot"
      # "ghostty"
      "google-chrome"
      # "hammerspoon"
      # "iina"
      # "istat-menus"
      # "iterm2"
      # "jordanbaird-ice"
      # "karabiner-elements"
      # "linearmouse"
      # "lm-studio"
      # "lm-studio"
      # "logitech-options"
      # "loopback"
      # "macwhisper"
      # "marta"
      # "mqtt-explorer"
      # "nextcloud"
      # "notion"
      # "obs"
      # "obsidian"
      "ollama-app"
      # "omnidisksweeper"
      # "openscad"
      # "openttd"
      # "orbstack"
      # "popclip"
      # "prusaslicer"
      # "raycast"
      # "screenflow"
      # "shortcat"
      # "signal"
      # "slack"
      # "soundsource"
      # "spotify"
      # "steam"
      # "viscosity"
      # "wireshark"
      # rogue amoeba
    ];

    # APPSTORE APPS
    masApps = {
      # "Amphetamine" = 937984704;
      # "AutoMounter" = 1160435653;
      # "Bitwarden" = 1352778147;
      # "Creator's Best Friend" = 1524172135;
      # "DaVinci Resolve" = 571213070;
      # "Disk Speed Test" = 425264550;
      # "Fantastical" = 975937182;
      "Home Assistant Companion" = 1099568401;
      # "Ivory for Mastodon by Tapbots" = 6444602274;
      # "Microsoft Remote Desktop" = 1295203466;
      # "Perplexity" = 6714467650;
      # "Resize Master" = 1025306797;
      # "rCmd" = 1596283165;
      # "Snippety" = 1530751461;
      # "Tailscale" = 1475387142;
      # "Telegram" = 747648890;
      # "The Unarchiver" = 425424353;
      # "Todoist" = 585829637;
      # "UTM" = 1538878817;
      "WireGuard" = 1451685025;

      # "Keynote" = 409183694;
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
    };
  };
}
