{ config, pkgs, inputs, user, home, ... }:

{

  # Common across all machines and users
  imports = [ ./eza.nix ./fzf.nix ./tmux.nix ./vim.nix ./zsh.nix ];

  home.stateVersion = "21.11";
  home = {
    username = user;
    homeDirectory = home;
  };

  home.packages = with pkgs;
    [
      bat
      curl
      fd
      fzf
      gh
      git
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
      wget
      zsh

      # Code
      stylua
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
      lua-language-server
      # nodePackages.vscode-json-languageserver
      # tailwindcss-language-server
      # typescript-language-server
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux-only packages
      # direnv
    ];

  home.file = {
    ".local/scripts/ready-tmux".source =
      ../../modules/home-manager/scripts/ready-tmux;

    ".local/scripts/tmux-sessionizer".source =
      ../../modules/home-manager/scripts/tmux-sessionizer;

    # ".config/.p10k-rainbow.zsh".source =
    #   ../../modules/home-manager/dotfiles/.p10k-rainbow.zsh;

    # ".local/scripts/taoup" = {
    #   source = builtins.fetchGit {
    #     url = "https://github.com/globalcitizen/taoup";
    #     rev = "bd6f225edbd0babe58b09a836977e772ee1abbab";
    #   };
    # };
  };

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    # "home-manager=${inputs.home-manager}"
  ];

  programs.git = {
    enable = true;
    lfs = { enable = true; };
    settings = {
      credential.helper = "store";
      init.defaultBranch = "main";
      core.editor = "vim";
      core.autocrlf = "input";
      # commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  programs.direnv = pkgs.lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
