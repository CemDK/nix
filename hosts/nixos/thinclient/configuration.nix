{ config, host, pkgs, lib, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    ../../../modules/features/hyprland
  ];

  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # ============================================================================
  # USER
  # ============================================================================
  users.motd = "There is no motd ;)";
  users.users.cemdk = {
    isNormalUser = true;
    description = "CemDK";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = lib.getExe pkgs.zsh;
    packages = with pkgs;
      [
        tree
        #impala
      ];
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  # services.printing.enable = true;
  # services.openssh.enable = lib.mkDefault false;
  services.getty.autologinUser = "cemdk";

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.hostName = host;
  networking.firewall.allowedTCPPorts = [
    53317 # localsend port
  ];
  # networking.wireless.enable = true;
  #networking.wireless.iwd.enable = true;

  # ============================================================================
  # VIRTUALIZATION
  # ============================================================================
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.oci-containers.containers = { };
  virtualisation.oci-containers.backend = "podman";

  # ============================================================================
  # BOOTLOADER
  # ============================================================================
  # boot.loader.grub.device = "/dev/vda";
  # boot.loader.grub.enable = true;
  # boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ============================================================================
  # HARDWARE
  # ============================================================================
  # Enable TPlink Archer Nano Wifi Dongle 
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl88xxau-aircrack ];

  hardware.bluetooth.enable = true;
  hardware.uinput.enable = true;
  # input.touchpad.disable_while_typing = false;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = lib.mkDefault "25.05";
}
