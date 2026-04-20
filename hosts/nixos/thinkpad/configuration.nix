{
  inputs,
  self,
  user,
  ...
}:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    "${self}/hosts/nixos/common.nix"
    "${self}/hosts/nixos/desktop.nix"
    ./hardware-configuration.nix
    "${self}/modules/features/stylix"
    "${self}/modules/features/hyprland"
    "${self}/modules/features/steam"

    # Hardware Support: WiFi, GPU, microphone, trackpoint, touchpad
    # Power Efficiency: AMD P-State driver, TLP/power-profiles integration, SSD TRIM
    # Proper Drivers: AMD microcode, GPU acceleration, modern modesetting
    # Bug Fixes: Touchpad clicking, backlight control, sleep/suspend
    # Performance: Early KMS, hardware acceleration, CPU frequency scaling
    # Automatic Kernel Updates: Ensures minimum kernel versions for hardware support
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
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
  # SERVICES
  # ============================================================================
  services = {
    getty.autologinUser = user;
    gvfs.enable = true;
    udisks2.enable = true;
    dbus.enable = true;
  };

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.firewall.allowedTCPPorts = [
    53317 # localsend port
    5900 # vnc port
  ];

  # ============================================================================
  # BOOTLOADER
  # ============================================================================
  # boot.loader.grub.device = "/dev/vda";
  # boot.loader.grub.enable = true;
  # boot.loader.grub.useOSProber = true;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ============================================================================
  # HARDWARE
  # ============================================================================
  hardware = {
    bluetooth.enable = true;
    uinput.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  # input.touchpad.disable_while_typing = false;

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = "25.05";
}
