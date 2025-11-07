# NOTE: This is a placeholder to allow the flake to evaluate.
# The actual hardware configuration will be generated during installation.
{ lib, ... }:

{
  # Placeholder values - will be replaced during installation
  boot.initrd.availableKernelModules = lib.mkDefault [ ];
  boot.initrd.kernelModules = lib.mkDefault [ ];
  boot.kernelModules = lib.mkDefault [ ];
  boot.extraModulePackages = lib.mkDefault [ ];

  # Placeholder filesystem - will be replaced during installation
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = lib.mkDefault [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
