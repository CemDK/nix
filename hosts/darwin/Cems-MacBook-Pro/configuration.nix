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

  system.stateVersion = 6;

  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      PermitRootLogin no
      KbdInteractiveAuthentication no
      AllowUsers cemdk
      MaxAuthTries 5
      LogLevel VERBOSE
    '';
  };

}
