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
    ../../../../modules/containers/traefik.nix
  ];

  # ============================================================================
  # ENVIRONMENT
  # ============================================================================
  # environment.variables = {
  #   KEY = "VALUE";
  # };

  # ============================================================================
  # VIRTUALIZATION
  # ============================================================================
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        homer = import ../../../../modules/containers/homer.nix;
      };
    };
  };

  # Enable Podman socket so Traefik can discover containers
  systemd.sockets."podman".enable = true;

  # ============================================================================
  # SERVICES
  # ============================================================================
  services.getty.autologinUser = "cemdk";

  systemd.services.create-podman-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-homer.service"
      "${backend}-traefik.service"
    ];
    script = ''
      ${pkgs.podman}/bin/podman network exists traefik_network || \
        ${pkgs.podman}/bin/podman network create --driver=bridge traefik_network
    '';
  };

  system.activationScripts = {
    script.text = ''
      install -d -m 755 /home/cemdk/docker/homer/assets -o root -g root
    '';
  };

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.hostName = host;
  networking.firewall.allowedTCPPorts = [
    53317 # localsend port
    80 # traefik http
    443 # traefik https
    8080 # traefik dashboard
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

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = lib.mkDefault "25.05";
}
