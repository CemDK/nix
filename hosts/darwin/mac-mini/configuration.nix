{ self, ... }:
{
  imports = [
    "${self}/hosts/darwin/common.nix"
    ./packages.nix
    ./brew.nix
  ];

  system.stateVersion = 6;
  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.swipescrolldirection" = false;
}
