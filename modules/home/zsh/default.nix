{
  config,
  pkgs,
  lib,
  ...
}:
{

  programs = {
    zoxide.enable = true;

    starship = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ../../../dotfiles/starship/starship.toml);
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      autocd = true;

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
      # Full compinit (with compaudit security scan) only when the dump is older
      # than 24h; otherwise trust the cache (-C). Compile the dump in the
      # background so sourcing it is faster on the next startup.
      completionInit = ''
        # skip the autoload when compinit is already loaded (e.g. re-sourcing .zshrc),
        # since autoload discards the loaded function and forces a reload from fpath
        (( $+functions[compinit] )) || autoload -U compinit
        if [[ -n $ZDOTDIR/.zcompdump(#qN.mh-24) ]]; then
          compinit -C
        else
          compinit
        fi
        {
          if [[ -s $ZDOTDIR/.zcompdump && (! -s $ZDOTDIR/.zcompdump.zwc || $ZDOTDIR/.zcompdump -nt $ZDOTDIR/.zcompdump.zwc) ]]; then
            zcompile $ZDOTDIR/.zcompdump
          fi
        } &!
      '';

      shellAliases = import ./aliases.nix;
      envExtra = ''
        PATH=$PATH:${config.home.homeDirectory}/.cargo/bin
        PATH=$PATH:${config.home.homeDirectory}/.local/scripts
        PATH=$PATH:${config.home.homeDirectory}/.local/bin
      '';

      initContent = ''

        export WAKATIME_HOME=$XDG_CONFIG_HOME/wakatime

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
      + import ./init.nix { inherit pkgs config lib; }
      + import ./functions.nix { inherit pkgs lib; };
    };
  };
}
