{ pkgs, ... }: {
  programs.zoxide.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    shellAliases = import ./aliases.nix;

    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./dotfiles/.p10k-rainbow.zsh}

      export ZSH_COMPDUMP=$HOME/.cache/.zcompdump-$HOST
      SAVEHIST=10000
      HISTSIZE=9999
      HISTFILE=$HOME/.config/zsh/.zsh_history
      setopt share_history
      setopt hist_expire_dups_first
      setopt hist_ignore_dups
      setopt hist_verify
      bindkey "^[[A" history-search-backward
      bindkey "^[[B" history-search-forward

      eval "$(zoxide init zsh)"
    '';
  };
}
