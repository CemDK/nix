{ pkgs, lib, inputs, host, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    ../../../modules/features/hyprland

    # Hardware Support: WiFi, GPU, microphone, trackpoint, touchpad
    # Power Efficiency: AMD P-State driver, TLP/power-profiles integration, SSD TRIM
    # Proper Drivers: AMD microcode, GPU acceleration, modern modesetting
    # Bug Fixes: Touchpad clicking, backlight control, sleep/suspend
    # Performance: Early KMS, hardware acceleration, CPU frequency scaling
    # Automatic Kernel Updates: Ensures minimum kernel versions for hardware support
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
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
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    # openssh.enable = lib.mkDefault false;
    # printing.enable = true;
    getty.autologinUser = "cemdk";
    gvfs.enable = true;
    udisks2.enable = true;

    dbus.enable = true;
  };

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.hostName = host;
  networking.firewall.allowedTCPPorts = [
    53317 # localsend port
    5900 # vnc port
  ];
  # networking.wireless.iwd.enable = true;

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
  hardware.bluetooth.enable = true;
  hardware.uinput.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # input.touchpad.disable_while_typing = false;

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = lib.mkDefault "25.05";
}
