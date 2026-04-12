{
  config,
  pkgs,
  lib,
  ...
}:
let
  scripts = import ./scripts.nix { inherit pkgs; };

  link = config.lib.file.mkOutOfStoreSymlink;
  localFiles = "${config.home.homeDirectory}/.config/nix/dotfiles";
  configs = {
    alacritty = "${localFiles}/alacritty";
    hypr = "${localFiles}/hypr";
    neovide = "${localFiles}/neovide";
    rofi = "${localFiles}/rofi";
    tmux = "${localFiles}/tmux";
    waybar = "${localFiles}/waybar";
    wallpapers = "${localFiles}/wallpapers";
  };
in
{
  imports = [
    #
    ./nvim
    ./fzf
    ./zsh
  ];

  home = {
    packages =
      with pkgs;
      [
        # ---------------------------------
        # Packages managed by home-manager
        # ---------------------------------
        # eza
        # fzf
        # gh
        # zsh
        # ---------------------------------

        alacritty
        bat
        btop
        curl
        fd
        git
        gnumake
        htop
        jq
        lazygit
        localsend
        neovide
        neovim
        obsidian
        ripgrep
        starship
        tldr
        tmux
        unzip
        vim
        wget

      ]
      ++ builtins.attrValues scripts
      ++ lib.optionals pkgs.stdenv.isLinux [
        # Linux-only packages
        # anki # using brew for macos
      ];
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  xdg.configFile = builtins.mapAttrs (name: config: {
    source = link "${config}";
    recursive = true;
  }) configs;

  home.file = {
    ".local/scripts/ready-tmux".source = ../../dotfiles/scripts/ready-tmux;
    ".local/scripts/tmux-sessionizer".source = ../../dotfiles/scripts/tmux-sessionizer;
  };

  # ============================================================================
  # EXTRA PROGRAMS
  # ============================================================================
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    signing.format = null;
    lfs = {
      enable = true;
    };
    settings = {
      user = {
        name = "CemDK";
        email = "25245902+CemDK@users.noreply.github.com";
      };
      credential.helper = "store";
      init.defaultBranch = "main";
      core.editor = "vim";
      core.autocrlf = "input";
      # commit.gpgsign = true;
      push = {
        default = "simple";
        followTags = true;
        autoSetupRemote = true;
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
    ignores = [
      "**/.claude/settings.local.json"
      ".DS_Store"
      ".direnv"
      ".env*"
      ".envrc"
      "zHide" # I have neo-tree rules to hide clutter under this file
    ];
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.direnv = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # ============================================================================
  # NIX GENERATION CLEANUP
  # ============================================================================
  # The nix.gc timer in common.nix handles nix-collect-garbage, but doesn't
  # expire home-manager generations or nix profile history. This timer covers
  # those two so old generations don't keep the store bloated.
  systemd.user.services.nix-generation-cleanup = lib.mkIf pkgs.stdenv.isLinux {
    Unit.Description = "Expire old Nix and home-manager generations";
    Service = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "nix-generation-cleanup" ''
          MIN_KEEP=5

          # Expire home-manager generations older than 30 days, but always keep $MIN_KEEP
          total=$(${pkgs.home-manager}/bin/home-manager generations | ${pkgs.coreutils}/bin/wc -l)
          if [ "$total" -gt "$MIN_KEEP" ]; then
            ${pkgs.home-manager}/bin/home-manager expire-generations "-30 days" 2>/dev/null || true
          fi

          # Wipe old nix profile history, keeping at least $MIN_KEEP
          total=$(${pkgs.nix}/bin/nix profile history 2>/dev/null | ${pkgs.gnugrep}/bin/grep -c "^Version" || echo "0")
          if [ "$total" -gt "$MIN_KEEP" ]; then
            ${pkgs.nix}/bin/nix profile wipe-history --older-than 30d 2>/dev/null || true
          fi
        ''
      );
    };
  };

  systemd.user.timers.nix-generation-cleanup = lib.mkIf pkgs.stdenv.isLinux {
    Unit.Description = "Expire old Nix and home-manager generations";
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  gtk.gtk4.theme = null;
}
