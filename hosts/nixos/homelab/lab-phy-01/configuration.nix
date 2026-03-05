{
  config,
  self,
  user,
  host,
  pkgs,
  lib,
  ...
}:
let
  args = {
    configBase = "/home/${user}/.config/nix/modules/containers";
    storagePath = "/mnt/storage/data";
  };
  container = name: import "${self}/modules/containers/${name}" args;
in
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ../common.nix
    ./hardware-configuration.nix

    # TODO: Enable after setting up /etc/restic-password on target
    # "${self}/modules/backup.nix"

    # Import containers for this host
    (container "audiobookshelf")
    (container "calibre-web")
    (container "homer")
    (container "it-tools")
    (container "mealie")
    (container "navidrome")
    (container "traefik")
  ];

  # ============================================================================
  # SECRETS (sops-nix)
  # ============================================================================
  sops = {
    defaultSopsFile = "${self}/secrets/global.yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    age.keyFile = "~/.config/sops/age/keys.txt";
    age.generateKey = true;
    secrets = {
      "example/token" = {
        owner = config.users.users.${user}.name;
      };
    };
  };

  # ============================================================================
  # ENVIRONMENT
  # ============================================================================
  # environment.variables = {
  #   KEY = "VALUE";
  # };

  # ============================================================================
  # FILESYSTEMS
  # ============================================================================
  # TODO: look into disko and use it instead?
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/362EAAD12EAA8A07";
    fsType = "ntfs-3g";
    options = [
      "nofail" # don't block boot if drive is missing
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services.getty.autologinUser = "cemdk";
  services.samba = {
    enable = true;
    openFirewall = true; # opens ports 139, 445
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "lab-phy-01";
        "security" = "user";
        "map to guest" = "Bad User";
      };
      data = {
        path = "${args.storagePath}";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "${user}";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # Enable Podman socket so Traefik can discover containers
  systemd.sockets."podman".enable = true;

  systemd.services.create-podman-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    wantedBy = [
      "${backend}-homer.service"
      "${backend}-traefik.service"
      "${backend}-audiobookshelf.service"
      "${backend}-it-tools.service"
      "${backend}-navidrome.service"
      "${backend}-calibre-web.service"
      "${backend}-mealie.service"
    ];
    script = ''
      ${pkgs.podman}/bin/podman network exists traefik_network || \
        ${pkgs.podman}/bin/podman network create --driver=bridge traefik_network
    '';
  };

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.hostName = host;
  networking.firewall.allowedTCPPorts = [
    80
    443
    53317 # localsend
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
