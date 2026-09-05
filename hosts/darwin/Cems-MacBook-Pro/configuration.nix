{ self, ... }:
{
  imports = [
    "${self}/hosts/darwin/common.nix"
    ./packages.nix
    ./brew.nix
  ];

  # ============================================================================
  # HOST IDENTITY
  # ============================================================================
  common = {
    user = "cemdk";
    home = "/Users/cemdk";
  };
  nixpkgs.hostPlatform = "aarch64-darwin";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;

}
