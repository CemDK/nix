{ ... }:
{
  imports = [
    ../common.nix
    ./packages.nix
    ./brew.nix
  ];

  system.stateVersion = 6;
}
