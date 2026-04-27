{
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
  ];

  # ============================================================================
  # USER
  # ============================================================================
  users.motd = "There is no motd ;)";
  users.users.${user} = {
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
  services = {
    getty.autologinUser = user;
  };

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.firewall.allowedTCPPorts = [
    53317 # localsend port
  ];

  # ============================================================================
  # BOOTLOADER
  # ============================================================================
  # boot.loader.grub.device = "/dev/vda";
  # boot.loader.grub.enable = true;
  # boot.loader.grub.useOSProber = true;
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "i915.fastboot=1" ];
    initrd.kernelModules = [ "i915" ];
  };

  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # ============================================================================
  # HARDWARE
  # ============================================================================
  hardware = {
    bluetooth.enable = true;
    uinput.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;

      # extraPackages = with pkgs; [
      #   intel-media-driver # VAAPI for Gemini Lake+
      #   intel-compute-runtime-legacy1 # OpenCL
      #   # vaapiVdpau
      #   libvdpau-va-gl
      # ];
    };
  };

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = "25.05";
}
