''
  if [[ $(uname) == "Darwin" ]]; then
    alias activate-settings="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u"
    alias nixswitch="darwin-rebuild switch --flake ~/.config/nix/.#$(whoami)@work && activate-settings"
    if [[ $(uname -m) == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    # Linux
    alias pbcopy='xclip -selection clipboard'
    alias nixswitch="nix run nixpkgs#home-manager --extra-experimental-features \"nix-command flakes\" -- switch --flake ~/.config/nix/.#$(whoami)@$(hostname -s)"
  fi


  # >>> conda initialize >>>
     # !! Contents within this block are managed by 'conda init' !!
     __conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
     if [ $? -eq 0 ]; then
       eval "$__conda_setup"
     else
        if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
           . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
        else
          export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
        fi
     fi
     unset __conda_setup
  # <<< conda initialize <<<


  # if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  #   exec tmux
  # fi
''
