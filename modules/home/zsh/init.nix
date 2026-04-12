{
  pkgs,
  config,
  lib,
}:
lib.optionalString pkgs.stdenv.isDarwin ''
  alias activate-settings="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u"
  alias nixswitch="sudo darwin-rebuild switch --flake ~/.config/nix/.#$(hostname -s)"
  eval "$(/usr/local/bin/brew shellenv)"
''
+ lib.optionalString (pkgs.stdenv.isLinux && !config.targets.genericLinux.enable) ''
  alias nixswitch="sudo nixos-rebuild switch --flake ~/.config/nix/.#$(hostname -s)"
''
+ lib.optionalString config.targets.genericLinux.enable ''
  alias pbcopy='xclip -selection clipboard'
  alias nixswitch="nix --extra-experimental-features nix-command --extra-experimental-features flakes run nixpkgs#home-manager -- switch --flake ~/.config/nix/.#$(hostname -s)"
''
+ ''

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
