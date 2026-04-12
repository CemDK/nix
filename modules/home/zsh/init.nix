{
  pkgs,
  config,
  lib,
}:
lib.optionalString pkgs.stdenv.isDarwin ''
  alias activate-settings="/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u"
  eval "$(/usr/local/bin/brew shellenv)"

  # >>> conda initialize >>>
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
+ lib.optionalString config.targets.genericLinux.enable ''
  alias pbcopy='xclip -selection clipboard'
''
# Common for all configs:
+ ''
  if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)";
  fi
''
