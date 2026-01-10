{ config, ... }:
{

  programs.zoxide.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      aws.disabled = true;
      gcloud.disabled = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # dotDir expects a relative path from home directory, not absolute
    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [ "git" "docker" ];
    # };

    # ============================================================================
    # HISTORY
    # ============================================================================
    history = {
      path = "$HOME/.config/zsh/.history";
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
        "nv"
        "nvim"
        "nvime"
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

    # ============================================================================
    # INIT
    # ============================================================================
    shellAliases = import ./aliases.nix;
    envExtra = ''
      PATH=$PATH:${config.home.homeDirectory}/.cargo/bin
      PATH=$PATH:${config.home.homeDirectory}/go/bin
      PATH=$PATH:${config.home.homeDirectory}/.npm-global/bin
      PATH=$PATH:${config.home.homeDirectory}/.local/scripts
    '';

    initContent = ''

      export COMPDUMP=$HOME/.cache/.zcompdump-$HOST
      export WAKATIME_HOME=$XDG_CONFIG_HOME/wakatime

      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"


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

      # Bind space to magic-space (expand aliases in the middle of a command)
      bindkey ' ' magic-space

      # Open buffer line in editor
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey '^x^e' edit-command-line


    ''
    + import ./init.nix
    + import ./functions.nix;
  };
}
