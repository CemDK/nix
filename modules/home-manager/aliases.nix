{
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
