{
  config,
  pkgs,
  lib,
  ...
}:
let
  stack = "arr-stack";

  shared = config.homelab.containers;
  cfg = config.homelab.containers.${stack};

  helpers = import ../helpers.nix { inherit lib; };

  labels =
    lib.foldlAttrs
      (
        acc: name: svc:
        acc
        // helpers.mkTraefikLabels {
          inherit name;
          inherit (svc) port;
          url = shared.${name}.url;
          middlewares = [ "vpn-whitelist@file" ];
        }
      )
      {
        "traefik.docker.network" = cfg.networks.media.name;
      }
      cfg.services;

in
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ./sabnzbd.nix
    ./sonarr.nix
    ./radarr.nix
    ./seerr.nix
  ];

  # ============================================================================
  # OPTIONS
  # ============================================================================
  options.homelab.containers.${stack} = {
    enable = lib.mkEnableOption {
      description = "Enable ${stack} (wireguard, sabnzbd, sonarr, radarr, seerr)";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "${shared.configPath}/${stack}";
    };
    services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.port = lib.mkOption { type = lib.types.str; };
        }
      );
      default = { };
    };
    networks = {
      egress = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "arr_egress";
          description = "Name of the arr stack egress network.";
        };
        subnet = lib.mkOption {
          type = lib.types.str;
          default = "10.89.1.0/24";
          description = "Subnet for the arr stack egress network.";
        };
      };
      media = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "arr_media_internal";
          description = "Name of the arr stack internal media network.";
        };
        subnet = lib.mkOption {
          type = lib.types.str;
          default = "10.89.2.0/24";
          description = "Subnet for the arr stack internal media network.";
        };
      };
    };
    wireguard.containerConfig = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = {
        dependsOn = [ "wireguard" ];
        extraOptions = [
          "--network=container:wireguard"
          "--cap-drop=ALL"
          "--cap-add=CHOWN"
          "--cap-add=DAC_OVERRIDE"
          "--cap-add=FOWNER"
          "--cap-add=SETUID"
          "--cap-add=SETGID"
          "--security-opt=no-new-privileges"
        ];
      };
    };
  };

  # ============================================================================
  # CONFIG
  # ============================================================================
  config = lib.mkIf cfg.enable {
    homelab.containers.networks.consumers = [ "wireguard" ];
    homelab.containers.requiredDirs = [
      { directory = "${cfg.configDir}/wireguard/data/config"; }
      { directory = "${shared.storagePath}"; }
      { directory = "${shared.storagePath}/media/tv"; }
      { directory = "${shared.storagePath}/media/movies"; }
      { directory = "${shared.storagePath}/usenet/complete"; }
    ];

    virtualisation.oci-containers.containers.wireguard = {
      image = "lscr.io/linuxserver/wireguard:latest";
      pull = "newer";
      hostname = "wireguard";
      networks = [
        cfg.networks.egress.name
        cfg.networks.media.name
      ];

      environment = shared.environment // {
        "LOG_CONFS" = "true";
      };

      volumes = [
        "${cfg.configDir}/wireguard/data/config:/config"
        "/run/booted-system/kernel-modules/lib/modules:/lib/modules:ro"
      ];

      capabilities = {
        net_admin = true;
        chown = true;
        dac_override = true;
        fowner = true;
        setuid = true;
        setgid = true;
      };

      extraOptions = [
        "--cap-drop=ALL"
        "--security-opt=no-new-privileges"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
        "--dns=8.8.8.8"
      ];

      labels = labels;
    };

    # Each arr service waits for the wireguard tunnel to be up before starting
    systemd.services = builtins.listToAttrs (
      map (name: {
        name = "podman-${name}";
        value = {
          after = [
            "podman-wireguard.service"
            "ensure-container-dirs.service"
          ];
          requires = [ "podman-wireguard.service" ];
          bindsTo = [ "podman-wireguard.service" ];
          partOf = [ "podman-wireguard.service" ];
          serviceConfig = {
            ExecStartPre = [
              (pkgs.writeShellScript "wait-for-wireguard-tunnel" ''
                set -eu
                for _ in $(seq 1 30); do
                  if ${pkgs.podman}/bin/podman exec wireguard /bin/sh -c \
                    'ip link show wg0 >/dev/null 2>&1 && wg show wg0 >/dev/null 2>&1' \
                    2>/dev/null; then
                    exit 0
                  fi
                  sleep 5
                done
                echo "wireguard tunnel did not become ready in time" >&2
                exit 1
              '')
            ];
            TimeoutStartSec = lib.mkForce "180";
          };
        };
      }) (lib.attrNames cfg.services)
    );
  };
}
