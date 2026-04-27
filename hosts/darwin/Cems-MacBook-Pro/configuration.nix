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

  users.users.cemdk.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTgQK2vF0UiGGGTs2jZFTG2JdfMQgeshmnABQXXFzgvWjdoR0ev5nfnM6CXTSeNKCuxE/P0B3xth4nX4aSANvshWNTfhuR7BBjjMK0TrGVg6OW0ihIoju544NQ1YXcbMRIxGLZ7wXCKhsgdXQ9xACBcDmqz/zMJoSjWflncZ2dCxTbCJfvy888dGpnW+xI+zdcwG2ntUVYrpl9m2zJu5VVg+CEweQOzCUQ3l2s+agTbiQTNaImkLBTw7l58iEUSkMcRvhGKi7LnyvdAX1/nro4xoLu+jYb/+aBEtLbsvzDlAzlSTscTNXcReOqn+A+MjgwJWzzvG/WqgGWja0AoOLJ3ZbZk542nF6FL5d1cvyApFebBfLesOmWXkaD3OXBLeprpQlU4Dt8j7h1hgUmvK31diGXeg6eforstP7s+b56I22TsT5buVs6FqSBKkp/E2vOX1nJuyEVFt9mR1v2a5dzKC/wgjnI35Oscy7pQJapSehCopnvOD0Yx30LuVTmdPc= cem@Cem-Ryzen"
  ];
}
