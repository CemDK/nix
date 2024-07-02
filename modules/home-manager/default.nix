{ pkgs, ... }: {
  home.stateVersion = "24.05";
  home.username = "cem";
  home.packages = with pkgs; [
    less
  ];

  home.sessionVariables = {
    CLICOLOR = 1;
    EDITOR = "nvim";
  };

  programs.vim = {
    enable = true;
    extraConfig = ''
      set autoindent
      set expandtab
      set number
      set shiftwidth=4
      set smartindent
      set softtabstop=4
      set tabstop=4
    '';
    plugins = [pkgs.vimPlugins.colorizer];
  };
  

  programs.eza.enable = true;
  programs.zoxide.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      nixrebuild = "darwin-rebuild build --flake ~/.config/nix-darwin/.#CemDK-MBP";
      nixswitch = "nix run nix-darwin -- switch --flake ~/.config/nix-darwin";
      nixup = "pushd ~/src/system-config; nix flake update; nixswitch; popd";
      cd = "z";
      cat = "bat";
    };

    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./.p10k-rainbow.zsh}

      SAVEHIST=10000
      HISTSIZE=9999
      setopt share_history
      setopt hist_expire_dups_first
      setopt hist_ignore_dups
      setopt hist_verify
      bindkey "^[[A" history-search-backward
      bindkey "^[[B" history-search-forward

      eval "$(zoxide init zsh)"
    '';
      #source ${./.p10k.zsh}

  };

  programs.neovim.enable = true;
  programs.neovim.coc.enable = true;
  programs.neovim.extraConfig = ''
    set number
  '';

  home.file.".config/alacritty/themes".source = pkgs.fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "a4041aeea19d425b63f7ace868917da26aa189bd";
    sha256 = "sha256-A5Xlu6kqB04pbBWMi2eL+pp6dYi4MzgZdNVKztkJhcg=";
  };

  home.file.".p10k-rainbow.zsh".source = ./.p10k-rainbow.zsh;

  home.file.".config/alacritty/custom-themes/coolnight.toml".source = ./coolnight.toml;
  home.file.".config/alacritty/custom-themes/orange-and-teal.toml".source = ./orange-and-teal.toml;

  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    #import = ["~/.config/alacritty/themes/themes/solarized_dark.toml"];
    import = ["~/.config/alacritty/custom-themes/orange-and-teal.toml"];
    env = {
       TERM = "xterm-256color";
    };
    window = {
      padding.x = 10;
      padding.y = 10;

      decorations = "Buttonless";

      opacity = 0.8;
      blur = true;
      option_as_alt = "Both";
    };
    font = {
      normal.family = "MesloLGS Nerd Font Mono";
      size = 14;
    };
    #window.dimensions = {
      #lines = 80;
      #columns = 150;
    #};

  };
}
