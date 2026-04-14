{
  self,
  pkgs,
  lib,
  ...
}:
{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [ "${self}/hosts/common.nix" ];

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = [ "@wheel" ];

  # ============================================================================
  # USER MANAGEMENT
  # ============================================================================
  users.users.cemdk = {
    isNormalUser = true;
    description = "CemDK";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTgQK2vF0UiGGGTs2jZFTG2JdfMQgeshmnABQXXFzgvWjdoR0ev5nfnM6CXTSeNKCuxE/P0B3xth4nX4aSANvshWNTfhuR7BBjjMK0TrGVg6OW0ihIoju544NQ1YXcbMRIxGLZ7wXCKhsgdXQ9xACBcDmqz/zMJoSjWflncZ2dCxTbCJfvy888dGpnW+xI+zdcwG2ntUVYrpl9m2zJu5VVg+CEweQOzCUQ3l2s+agTbiQTNaImkLBTw7l58iEUSkMcRvhGKi7LnyvdAX1/nro4xoLu+jYb/+aBEtLbsvzDlAzlSTscTNXcReOqn+A+MjgwJWzzvG/WqgGWja0AoOLJ3ZbZk542nF6FL5d1cvyApFebBfLesOmWXkaD3OXBLeprpQlU4Dt8j7h1hgUmvK31diGXeg6eforstP7s+b56I22TsT5buVs6FqSBKkp/E2vOX1nJuyEVFt9mR1v2a5dzKC/wgjnI35Oscy7pQJapSehCopnvOD0Yx30LuVTmdPc= cem@Cem-Ryzen"
    ];
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };

    };
    gnome.gnome-keyring.enable = true;
    fwupd.enable = true;
  };

  # ============================================================================
  # SECURITY
  # ============================================================================
  security.sudo.wheelNeedsPassword = false;

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ]; # SSH

  # ============================================================================
  # LOCALIZATION & TIMEZONE
  # ============================================================================
  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = lib.mkDefault "de_DE.UTF-8";
    LC_IDENTIFICATION = lib.mkDefault "de_DE.UTF-8";
    LC_MEASUREMENT = lib.mkDefault "de_DE.UTF-8";
    LC_MONETARY = lib.mkDefault "de_DE.UTF-8";
    LC_NAME = lib.mkDefault "de_DE.UTF-8";
    LC_NUMERIC = lib.mkDefault "de_DE.UTF-8";
    LC_PAPER = lib.mkDefault "de_DE.UTF-8";
    LC_TELEPHONE = lib.mkDefault "de_DE.UTF-8";
    LC_TIME = lib.mkDefault "de_DE.UTF-8";
  };

  # ============================================================================
  # INPUT & KEYBOARD
  # ============================================================================
  services.xserver.xkb = {
    layout = lib.mkDefault "us";
    variant = "";
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    curl
    lazygit
    wget
  ];
}
