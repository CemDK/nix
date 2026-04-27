{
  config,
  self,
  user,
  host,
  pkgs,
  ...
}:
let
  cfg = config.homelab.containers;

  container = name: import "${self}/modules/containers/${name}";
in
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    "${self}/hosts/nixos/homelab/common.nix"
    ./hardware-configuration.nix

    "${self}/modules/backup.nix"

    # Homelab options
    "${self}/hosts/nixos/homelab/options.nix"

    # Container options and modules
    "${self}/modules/containers/options.nix"
    (container "arr")
    (container "audiobookshelf")
    (container "calibre-web")
    (container "homer")
    (container "it-tools")
    (container "mealie")
    (container "navidrome")
    (container "traefik")
  ];

  # ============================================================================
  # ENVIRONMENT
  # ============================================================================
  # environment.variables = {
  #   KEY = "VALUE";
  # };

  # ============================================================================
  # HOMELAB
  # ============================================================================
  homelab = {
    domain = "cemdk.net";

    containers = {
      configPath = "/home/${user}/.config/nix/modules/containers";
      storagePath = "/mnt/storage/data";

      arr.enable = true;
      audiobookshelf.enable = true;
      calibre-web.enable = true;
      homer.enable = true;
      it-tools.enable = true;
      mealie.enable = true;
      navidrome.enable = true;
      traefik.enable = true;

      # networks = {
      # traefik = "traefik_network";

      # arr = {
      #   vpn = {
      #     egress = {
      #       name = "vpn_egress_network";
      #       subnet = "10.89.1.0/24";
      #     };
      #     media = {
      #       name = "vpn_media_network";
      #       subnet = "10.89.2.0/24";
      #     };
      #   };
      # };

      #   networkConsumers = [
      #     "audiobookshelf"
      #     "calibre-web"
      #     "homer"
      #     "it-tools"
      #     "mealie"
      #     "arr"
      #     "navidrome"
      #   ];
      # };
    };
  };

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

  fileSystems."/mnt/backups/containers" = {
    device = "/dev/disk/by-uuid/024b126d-17fb-41e8-8652-b00ecc2da3c6";
    fsType = "ext4";
    options = [
      "nofail" # don't block boot if USB is unplugged
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    getty.autologinUser = user;
    samba-wsdd.enable = true;
    samba = {
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
          path = "${cfg.storagePath}";
          browseable = "yes";
          "read only" = "no";
          "valid users" = "${user}";
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };
  };

  # Enable Podman socket so Traefik can discover containers
  systemd.sockets."podman".enable = true;

  systemd.services =
    (builtins.listToAttrs (
      map (name: {
        name = "podman-${name}";
        value = {
          after = [
            "ensure-container-dirs.service"
            "create-podman-network.service"
          ];
          requires = [ "create-podman-network.service" ];
        };
      }) cfg.networkConsumers
    ))
    // {
      create-podman-network = with config.virtualisation.oci-containers; {
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        wantedBy = [ "multi-user.target" ];
        before = map (name: "${backend}-${name}.service") cfg.networkConsumers;
        script = ''
          # Create traefik_network
          ${pkgs.podman}/bin/podman network exists ${cfg.networks.traefik} || \
            ${pkgs.podman}/bin/podman network create --driver=bridge ${cfg.networks.traefik}
          # Create VPN egress network
          ${pkgs.podman}/bin/podman network exists ${cfg.networks.vpnEgress} || \
            ${pkgs.podman}/bin/podman network create \
              --driver=bridge \
              --subnet ${cfg.networks.vpnEgressSubnet} \
              ${cfg.networks.vpnEgress}
          # Create VPN media internal network
          ${pkgs.podman}/bin/podman network exists ${cfg.networks.vpnMedia} || \
            ${pkgs.podman}/bin/podman network create \
              --driver=bridge \
              --internal \
              --subnet ${cfg.networks.vpnMediaSubnet} \
              ${cfg.networks.vpnMedia}
        '';
      };
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
  # SECRETS (sops-nix)
  # ============================================================================
  sops = {
    defaultSopsFile = "${self}/secrets/global.yaml";
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "~/.config/sops/age/keys.txt";
      generateKey = true;
    };
    secrets = {
      "example/token" = {
        owner = config.users.users.${user}.name;
      };
    };
  };

  # ============================================================================
  # BOOTLOADER
  # ============================================================================
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "i915.fastboot=1" ];
    initrd.kernelModules = [ "i915" ];
  };

  # ============================================================================
  # HARDWARE
  # ============================================================================
  hardware.bluetooth.enable = true;
  hardware.uinput.enable = true;

  # ============================================================================
  # SYSTEM
  # ============================================================================
  system.stateVersion = "25.05";
}
