{
  lib,
  user,
  config,
  ...
}:
let
  cfg = config.homelab.containers;
in
{
  options.homelab = {
    containers = {
      requiredDirs = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              directory = lib.mkOption { type = lib.types.str; };
              owner = lib.mkOption {
                type = lib.types.str;
                default = user;
              };
              group = lib.mkOption {
                type = lib.types.str;
                default = "users";
              };
              mode = lib.mkOption {
                type = lib.types.str;
                default = "0755";
              };
            };
          }
        );
        default = [ ];
        description = "Directories required by containers, created before any container starts.";
      };

      configPath = lib.mkOption {
        type = lib.types.str;
        default = "/home/${user}/.config/nix/modules/containers";
        description = "Base path for container configuration files.";
      };

      storagePath = lib.mkOption {
        type = lib.types.str;
        default = "/mnt/storage/data";
        description = "Base path for persistent storage (media, downloads, etc).";
      };

      commonEnv = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          "TZ" = "Europe/Berlin";
          "PUID" = "1000";
          "PGID" = "100";
        };
        description = "Common environment variables shared across all containers.";
      };

      networks = {
        traefik = lib.mkOption {
          type = lib.types.str;
          default = "traefik_network";
          description = "Name of the Traefik network.";
        };

        vpnEgress = lib.mkOption {
          type = lib.types.str;
          default = "vpn_egress";
          description = "Name of the VPN egress network.";
        };

        vpnEgressSubnet = lib.mkOption {
          type = lib.types.str;
          default = "10.89.1.0/24";
          description = "Subnet for the VPN egress network.";
        };

        vpnMedia = lib.mkOption {
          type = lib.types.str;
          default = "vpn_media_internal";
          description = "Name of the VPN media internal network.";
        };

        vpnMediaSubnet = lib.mkOption {
          type = lib.types.str;
          default = "10.89.2.0/24";
          description = "Subnet for the VPN media internal network.";
        };
      };

      networkConsumers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "audiobookshelf"
          "calibre-web"
          "homer"
          "it-tools"
          "mealie"
          "navidrome"
          "traefik"
          "wireguard"
        ];
        description = "Container names that depend on podman networks being created first.";
      };
    };
  };

  config = lib.mkIf (cfg.requiredDirs != [ ]) {
    systemd.services.ensure-container-dirs = {
      description = "Create required directories for containers";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "multi-user.target" ];
      before = [ "create-podman-network.service" ];
      script = lib.concatMapStrings (
        d: "install -d -m ${d.mode} -o ${d.owner} -g ${d.group} ${d.directory}\n"
      ) cfg.requiredDirs;
    };
  };
}
