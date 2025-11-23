{ config, pkgs, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  localFiles = "${config.home.homeDirectory}/.config/nix/dotfiles";
  configs = {
    # aerospace = "${localFiles}/aerospace";
    alacritty = "${localFiles}/alacritty";
    hypr = "${localFiles}/hypr";
    rofi = "${localFiles}/rofi";
    tmux = "${localFiles}/tmux";
    waybar = "${localFiles}/waybar";
    wallpapers = "${localFiles}/wallpapers";
  };
in {
  imports = [
    #
    ./nvim
    ./fzf
    ./zsh
  ];

  home = {
    stateVersion = "25.05";

    packages = with pkgs; [
      alacritty
      bat
      btop
      curl
      # direnv # installed with brew on macos
      fd
      htop
      jq
      lazygit
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
    ".local/scripts/tmux-sessionizer".source =
      ../../dotfiles/scripts/tmux-sessionizer;
  };

  # ============================================================================
  # EXTRA PROGRAMS
  # ============================================================================
  programs.git = {
    enable = true;
    lfs = { enable = true; };
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
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = { enable = true; };
  };

  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [ "--group-directories-first" "--header" ];
  };
}
