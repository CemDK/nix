{
  nixrebuild = "darwin-rebuild build --flake ~/.config/nix/.#CemDK-MBP";
  nixswitch = "nix run nix-darwin -- switch --flake ~/.config/nix";
  nixup = "pushd ~/src/system-config; nix flake update; nixswitch; popd";
  cat = "bat";
  l = "ll";
  lt = "ll --tree";
  cd = "z";
  vif = "vi $(fzf --preview=\"bat --color=always {}\")";
  cdf = "cd $(fd --type directory | fzf --preview \"eza --tree --colour=always {}\")";
}
