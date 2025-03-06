{
  nixrebuild = ''
    darwin-rebuild build --flake ~/.config/nix/.#$(scutil --get ComputerName)"
  '';

  #nixswitch = "nix run nix-darwin -- switch --flake ~/.config/nix/.#$(hostname)";
  # nixswitch = ''
  #   darwin-rebuild switch --flake ~/.config/nix/.#$(scutil --get ComputerName) && activate-settings
  # '';

  nixswitch = ''
    pushd $HOME/.config/nix;
    nix run nixpkgs#home-manager --extra-experimental-features "nix-command flakes" -- switch --flake .#$(whoami)@$(hostname)
    popd
  '';

  activate-settings = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  nixup = "pushd ~/.config/nix; nix flake update; nixswitch; popd";
  cat = "bat";
  l = "ll";
  la = "lla";
  lt = "ll --tree";
  cd = "z";
  vi = "nvim";
  vim = "nvim";
  vif = "vi $(fzf --preview='bat --color=always {}' --preview-window=70%,top)";
  cdf = ''
    cd $(fd --type directory | fzf --preview-window=70%,top --preview "eza --tree --colour=always {}")
  '';
  cfile = "cat $(fzf) | pbcopy";

  tadev = "ENV=dev terragrunt apply";
  tddev = "ENV=dev terragrunt destroy";
  taprod = "ENV=prod terragrunt apply";
  tdprod = "ENV=prod terragrunt destroy";

  vimtip = ''
    curl -w "
    " https://vtip.43z.one'';
}
