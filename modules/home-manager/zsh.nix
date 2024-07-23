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
        ignorePatterns = [ "cd" "cd *" "pwd" "ls *" "l" "la" "ll" "lla" "lt" "exit"];
        save = 10001;
        size = 10000;
        share = true;

        expireDuplicatesFirst = true;
        ignoreDups = true;
    };

    historySubstringSearch = {
        # bindkey "^[[A" history-beginning-search-backward
        # bindkey "^[[B" history-beginning-search-forward
        enable = true;
        searchUpKey = [ "^[[A" "^P"];
        searchDownKey = [ "^[[B" "^N"];
    };

    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./dotfiles/.p10k-rainbow.zsh}

      eval "$(/opt/homebrew/bin/brew shellenv)"
      eval "$(zoxide init zsh)"

      export ZSH_COMPDUMP=$HOME/.cache/.zcompdump-$HOST

      setopt hist_verify
    '';
  };
}
