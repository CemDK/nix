{
  config,
  lib,
  pkgs,
  self,
  host,
  user,
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
  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [ "@wheel" ];
  };

  # ============================================================================
  # USER MANAGEMENT
  # ============================================================================
  users.users.${user} = {
    isNormalUser = true;
    description = "CemDK";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = config.common.sshKeys;
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
        AllowUsers = [
          "cemdk"
          "cem"
        ];
        MaxAuthTries = 5;
        LogLevel = "VERBOSE";
        KbdInteractiveAuthentication = false;
      };
      moduliFile = pkgs.runCommand "filter-moduli" { } ''
        awk '$5 >= 3071' "${config.programs.ssh.package}/etc/ssh/moduli" > "$out"
      '';
    };
    gnome.gnome-keyring.enable = true;
    fwupd.enable = true;
  };

  # ============================================================================
  # VIRTUALIZATION
  # ============================================================================
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers = {
      backend = "podman";
      containers = { };
    };
  };

  # ============================================================================
  # SECURITY
  # ============================================================================
  security.sudo.wheelNeedsPassword = false;

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking = {
    hostName = host;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH
    };
  };

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
