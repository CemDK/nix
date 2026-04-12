{ ... }:
{
  imports = [
    ../common.nix
    ./packages.nix
    ./brew.nix
  ];

  system.defaults.CustomUserPreferences.NSGlobalDomain."com.apple.swipescrolldirection" = false;
}
