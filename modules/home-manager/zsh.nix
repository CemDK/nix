{ pkgs, config, ... }: {
  programs.zoxide.enable = true;
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      # command_timeout = 1300;
      # scan_timeout = 50;
      aws.disabled = true;
      gcloud.disabled = true;
      # format = ''
      #   $all$nix_shell$nodejs$lua$golang$rust$php$git_branch$git_commit$git_state$git_status
      #   $username$hostname$directory'';
      # character = {
      #   success_symbol = "[](bold green) ";
      #   error_symbol = "[✗](bold red) ";
      # };
    };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [ "git" "docker" ];
    # };

    ########################################################
    # HISTORY
    ########################################################
    history = {
      path = "$HOME/.config/zsh/.zsh_history";
      ignorePatterns = [
        "cd"
        "cd *"
        "clear"
        "pwd"
        "ls*"
        "l"
        "la"
        "ll"
        "lla"
        "lt"
        "exit"
        "vi"
        "vif"
        "vim"
        "nvim"
      ];
      save = 100001;
      size = 100000;
      share = true;

      expireDuplicatesFirst = true;
      ignoreDups = true;
    };

    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^[[A" ];
      searchDownKey = [ "^[[B" ];
    };

    ########################################################
    # INIT
    ########################################################
    shellAliases = import ./zsh_aliases.nix;
    envExtra = ''
      PATH=$PATH:${config.home.homeDirectory}/.cargo/bin
      PATH=$PATH:${config.home.homeDirectory}/go/bin
      PATH=$PATH:${config.home.homeDirectory}/.npm-global/bin
      PATH=$PATH:${config.home.homeDirectory}/.local/scripts
    '';

    initContent = ''
      # source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      # source ${./dotfiles/.p10k-rainbow.zsh}

      export ZSH_COMPDUMP=$HOME/.cache/.zcompdump-$HOST

      eval "$(zoxide init zsh)"

      # HISTORY
      setopt MENU_COMPLETE
      setopt ALWAYS_TO_END
      setopt HIST_VERIFY

      bindkey "^P" history-beginning-search-backward
      bindkey "^N" history-beginning-search-forward
      bindkey '^ ' autosuggest-accept
      bindkey '^z' autosuggest-accept

      # Arrow key navigation of history
      bindkey '^[[1;5A' up-line-or-history
      bindkey '^[[1;5B' down-line-or-history
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word

    '' + import ./zsh_init.nix + import ./zsh_functions.nix;
  };
}
