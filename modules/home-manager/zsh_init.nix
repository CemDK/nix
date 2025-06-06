''
  if [[ $(uname) == "Darwin" ]]; then
    alias activate-settings="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u"
    if [[ $(uname -m) == "arm64" ]]; then
      alias nixswitch="sudo darwin-rebuild switch --flake ~/.config/nix/.#$(whoami)@work"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      alias nixswitch="sudo darwin-rebuild switch --flake ~/.config/nix/.#$(whoami)@$(hostname -s)"
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    if [[ $(uname -n) == "nixos" ]]; then
        alias nixswitch="sudo nixos-rebuild switch --flake ~/.config/nix/.#$(whoami)@$(hostname -s)"
    else
        # Linux
        alias pbcopy='xclip -selection clipboard'
        alias nixswitch="nix run nixpkgs#home-manager --extra-experimental-features \"nix-command flakes\" -- switch --flake ~/.config/nix/.#$(whoami)@$(hostname -s)"
    fi
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
''
