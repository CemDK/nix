{ pkgs, ... }: {
  programs.zoxide.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    shellAliases = import ./aliases.nix;
    history = {
        path = "$HOME/.config/zsh/.zsh_history";
        ignorePatterns = [ "cd" "cd *" "clear" "pwd" "ls" "ls *" "l" "la" "ll" "lla" "lt" "exit" "vi" "vif" "vim"];
        save = 10001;
        size = 10000;
        share = true;

        expireDuplicatesFirst = true;
        ignoreDups = true;
    };

    historySubstringSearch = {
        enable = true;
        searchUpKey = [ "^[[A" ];
        searchDownKey = [ "^[[B" ];
    };

    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./dotfiles/.p10k-rainbow.zsh}

      # eval for homebrew depending on machine type (Apple Silicon/Intel)
      if [[ $(uname -m) == 'arm64' ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
      else
          eval "$(/usr/local/bin/brew shellenv)"
      fi
      eval "$(zoxide init zsh)"

      bindkey "^P" history-beginning-search-backward
      bindkey "^N" history-beginning-search-forward
      bindkey '^ ' autosuggest-accept
  
      export ZSH_COMPDUMP=$HOME/.cache/.zcompdump-$HOST

      setopt hist_verify
    '';
  };
}
