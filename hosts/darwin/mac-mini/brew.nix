{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    global.autoUpdate = true;

    brews = [
      # "bitwarden-cli"
      # "neovim"
      # "ollama"
      # "tailscale"
      # "borders"
    ];
    taps = [
      # "FelixKratz/formulae" #sketchybar
    ];
    casks = [
      # "screenflow"
      # "cleanshot"
      # "adobe-creative-cloud"
      # "nikitabobko/tap/aerospace"
      # "alacritty"
      # "alcove"
      # "audacity"
      # # "balenaetcher"
      # "bambu-studio"
      # "bentobox"
      # "claude"
      # "claude-code"
      # "clop"
      # "discord"
      # "displaylink"
      # "docker"
      # "easy-move-plus-resize"
      # "element"
      # "elgato-camera-hub"
      # "elgato-control-center"
      # "elgato-stream-deck"
      # "firefox"
      # "flameshot"
      # "font-fira-code"
      # "font-fira-code-nerd-font"
      # "font-fira-mono-for-powerline"
      # "font-hack-nerd-font"
      # "font-jetbrains-mono-nerd-font"
      # "font-meslo-lg-nerd-font"
      # "ghostty"
      # "google-chrome"
      # "iina"
      # "hammerspoon"
      # "istat-menus"
      # "iterm2"
      # "jordanbaird-ice"
      # "karabiner-elements"
      # "lm-studio"
      # "logitech-options"
      # "macwhisper"
      # "marta"
      # "mqtt-explorer"
      # "music-decoy" # github/FuzzyIdeas/MusicDecoy
      # "nextcloud"
      # "notion"
      # "obs"
      # "obsidian"
      # "ollama-app"
      # "omnidisksweeper"
      # "orbstack"
      # "openscad"
      # "openttd"
      # "plexamp"
      # "popclip"
      # "prusaslicer"
      # "raycast"
      # "signal"
      # "shortcat"
      # "slack"
      # "spotify"
      # "steam"
      # "wireshark"
      # "viscosity"
      # "visual-studio-code"
      "vlc"
      # "lm-studio"

      # # rogue amoeba
      # "audio-hijack"
      # "farrago"
      # "loopback"
      # "soundsource"
    ];
    masApps = {
      # "Amphetamine" = 937984704;
      # "AutoMounter" = 1160435653;
      # "Bitwarden" = 1352778147;
      # "Creator's Best Friend" = 1524172135;
      "DaVinci Resolve" = 571213070;
      # "Disk Speed Test" = 425264550;
      # "Fantastical" = 975937182;
      # "Ivory for Mastodon by Tapbots" = 6444602274;
      "Home Assistant Companion" = 1099568401;
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
      # "Wireguard" = 1451685025;

      # "Final Cut Pro" = 424389933;

      # these apps only available via uk apple id
      # "Logic Pro" = 634148309;
      # "MainStage" = 634159523;
      # "Garageband" = 682658836;
      # "ShutterCount" = 720123827;
      # "Teleprompter" = 1533078079;

      # "Keynote" = 409183694;
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
    };
  };
}
