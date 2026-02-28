{
  config,
  host,
  pkgs,
  lib,
  ...
}:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # USER
  # ============================================================================
  users.motd = "There is no motd ;)";
  users.users.cemdk = {
    isNormalUser = true;
    description = "CemDK";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # ============================================================================
  # ENVIRONMENT
  # ============================================================================
  # environment.variables = {
  #   LIBVA_DRIVER_NAME = "iHD"; # Force Intel media driver
  # };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services.getty.autologinUser = "cemdk";

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.hostName = host;
  networking.firewall.allowedTCPPorts = [
    53317 # localsend port
  ];

  # ============================================================================
  # BOOTLOADER
  # ============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "i915.fastboot=1" ];
  boot.initrd.kernelModules = [ "i915" ];

  # ============================================================================
  # HARDWARE
  # ============================================================================
  hardware.bluetooth.enable = true;
  hardware.uinput.enable = true;

  # hardware.graphics = {
  #   enable = true;
  #   enable32Bit = true;
  # };

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = lib.mkDefault "25.05";
}
