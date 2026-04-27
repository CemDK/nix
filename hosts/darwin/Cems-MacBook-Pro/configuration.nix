{ self, ... }:
{
  imports = [
    "${self}/hosts/darwin/common.nix"
    ./packages.nix
    ./brew.nix
  ];

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
