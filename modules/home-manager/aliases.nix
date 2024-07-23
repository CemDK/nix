{
  nixrebuild = "darwin-rebuild build --flake ~/.config/nix/.#$(hostname -s)";
  #nixswitch = "nix run nix-darwin -- switch --flake ~/.config/nix/.#$(hostname)";
  nixswitch = "darwin-rebuild switch --flake ~/.config/nix/.#$(hostname -s)";
  nixup = "pushd ~/.config/nix; nix flake update; nixswitch; popd";
  cat = "bat";
  l = "ll";
  la = "lla";
  lt = "ll --tree";
  cd = "z";
  vif = "vi $(fzf --preview=\"bat --color=always {}\")";
  cdf = "cd $(fd --type directory | fzf --preview \"eza --tree --colour=always {}\")";

  tadev = "ENV=dev terragrunt apply";
  tddev = "ENV=dev terragrunt destroy";
  taprod = "ENV=prod terragrunt apply";
  tdprod = "ENV=prod terragrunt destroy";

  vimtip = "curl -w \"\n\" https://vtip.43z.one";
}
