{ config, pkgs, inputs, user, home, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  localFiles = "${config.home.homeDirectory}/.config/nix/dotfiles";
  configs = {
    alacritty = "${localFiles}/alacritty";
    hypr = "${localFiles}/hypr";
    rofi = "${localFiles}/rofi";
    tmux = "${localFiles}/tmux";
    waybar = "${localFiles}/waybar";
    wallpapers = "${localFiles}/wallpapers";
  };
in {
  imports = [
    ./nvim
    ./fzf
    # ./tmux.nix
    # ./vim.nix
    ./zsh
  ];

  home.stateVersion = "25.05";
  home = {
    username = user;
    homeDirectory = home;
  };

  home.packages = with pkgs; [
    bat
    curl
    fd
    # fzf
    # gh
    # git
    htop
    jq
    lazygit
    neovide
    neovim
    ripgrep
    starship
    tldr
    tmux
    unzip
    vim
    obsidian
    wget
    zsh

    blueberry

    # Code
    #    lua
    # luajitPackages.luarocks
    # nodejs
    # pnpm
    # rustup
    # typescript

    ###################
    # for nvim
    # tree-sitter
    # formatting / linting
    # nodePackages.prettier
    # statix # nix linter
    # nixd
    # nixfmt-classic
    # Let mason do these
    # eslint
    # eslint_d
    # lua-language-server
    # nodePackages.vscode-json-languageserver
    # tailwindcss-language-server
    # typescript-language-server
  ];

  home.file = {
    ".local/scripts/ready-tmux".source = ../../dotfiles/scripts/ready-tmux;
    ".local/scripts/tmux-sessionizer".source =
      ../../dotfiles/scripts/tmux-sessionizer;
  };

  xdg.configFile = builtins.mapAttrs (name: config: {
    source = link "${config}";
    recursive = true;
  }) configs;

  # Sets NIX_PATH to this flakes nixpkgs input path.
  # Legacy nix commands (nix-shell, nix-env) will then use the same nixpkgs version as this flake
  # Can probalby forgo
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  programs.git = {
    enable = true;
    userName = "CemDK";
    userEmail = "25245902+CemDK@users.noreply.github.com";
    extraConfig = { credential.helper = "store"; };
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

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    # direnvrcExtra = ''
    #   export FOO="foo"
    #   echo "loaded direnv!"
    # '';
  };
}
