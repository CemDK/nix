{ config, pkgs, inputs, user, home, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nix/dotfiles";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    alacritty = "alacritty";
    tmux = "tmux";
  };
in {
  imports = [ ./eza.nix ./fzf.nix ./tmux.nix ./vim.nix ./zsh.nix ];

  home.stateVersion = "25.05";
  home = {
    username = user;
    homeDirectory = home;
  };

  home.packages = with pkgs; [
    bat
    curl
    fd
    fzf
    gh
    git
    htop
    jq
    lazygit
    neofetch
    neovide
    neovim
    ripgrep
    tldr
    tmux
    unzip
    wget
    vim
    zsh

    # Code
    lua
    luajitPackages.luarocks
    nodejs
    pnpm
    rustup
    typescript

    ###################
    # for nvim
    tree-sitter
    # formatting / linting
    nodePackages.prettier
    statix # nix linter
    nixd
    nixfmt-classic
    # Let mason do these
    # eslint
    # eslint_d
    # lua-language-server
    # nodePackages.vscode-json-languageserver
    # tailwindcss-language-server
    # typescript-language-server
  ];

  home.file = {
    ".local/scripts/ready-tmux".source =
      ../../modules/home-manager/scripts/ready-tmux;

    ".local/scripts/tmux-sessionizer".source =
      ../../modules/home-manager/scripts/tmux-sessionizer;
  };

  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

  # Sets NIX_PATH to this flakes nixpkgs input path.
  # Legacy nix commands (nix-shell, nix-env) will then use the same nixpkgs version as this flake
  # Can probalby forgo
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  programs.git.enable = true;

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
