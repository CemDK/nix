''
  if [[ $(uname) == "Darwin" ]]; then
    alias activate-settings="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u"
      alias nixswitch="sudo darwin-rebuild switch --flake ~/.config/nix/.#$(hostname -s)"
      eval "$(/usr/local/bin/brew shellenv)"
  else
    # Check if we're running NixOS by looking for the NixOS marker file
    if [[ -f /etc/NIXOS ]] || grep -q "^ID=nixos$" /etc/os-release 2>/dev/null; then
        # NixOS system
        alias nixswitch="sudo nixos-rebuild switch --flake ~/.config/nix/.#$(hostname -s)"
    else
        # Other Linux distributions
        alias pbcopy='xclip -selection clipboard'
        alias nixswitch="nix run nixpkgs#home-manager --extra-experimental-features \"nix-command flakes\" -- switch --flake ~/.config/nix/.#$(hostname -s)"
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

  if command -v direnv > /dev/null; then
      eval "$(direnv hook zsh)";
  else
      echo "Direnv not installed";
  fi
''
