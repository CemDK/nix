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

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    tailscale.enable = true;
  };

  # --- Sleep: on AC the display may sleep, the system never idle-sleeps ------
  system.activationScripts.postActivation.text = ''
    echo "configuring sleep..." >&2
    pmset -c sleep 0 displaysleep 10
  '';

  system.stateVersion = 6;

}
