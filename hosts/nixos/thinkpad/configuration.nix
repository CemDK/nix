{ pkgs, lib, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    ../../../modules/features/hyprland
  ];

  programs.firefox.enable = true;
  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # ============================================================================
  # USER
  # ============================================================================
  users.motd = "There is no motd ;)";
  users.users.cemdk = {
    isNormalUser = true;
    description = "CemDK";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      alacritty
      neovim
      kitty
      tree
      #impala
    ];
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  # services.printing.enable = true;
  services.openssh.enable = lib.mkDefault false;
  services.getty.autologinUser = "cemdk";

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.hostName = "thinkpad";
  networking.firewall.allowedTCPPorts = [ ];
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
  # boot.extraModulePackages = [ config.boot.kernelPackages.rtl88xxau-aircrack ];

  hardware.bluetooth.enable = true;
  # input.touchpad.disable_while_typing = false;

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = lib.mkDefault "25.05";
}
