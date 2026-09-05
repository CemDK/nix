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
    enable = lib.mkEnableOption "${stack} (wireguard, sabnzbd, sonarr, radarr, seerr)";
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
    # TODO: template wg0.conf through Nix so the media subnet in the kill switch
    # iptables rules stays in sync with networks.media.subnet.
    # i.e. :
    # PostUp  = DROUTE=$(ip route | grep default | awk '{print $3}'); HOMENET=192.168.178.0/24; MEDIANET=10.89.2.0/24; ip route add $HOMENET via $DROUTE; iptables -I OUTPUT -d $HOMENET -j ACCEPT; iptables -I OUTPUT -d $MEDIANET -j ACCEPT; iptables -A OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
    # PreDown = DROUTE=$(ip route | grep default | awk '{print $3}'); HOMENET=192.168.178.0/24; MEDIANET=10.89.2.0/24; ip route del $HOMENET via $DROUTE; iptables -D OUTPUT -d $HOMENET -j ACCEPT; iptables -D OUTPUT -d $MEDIANET -j ACCEPT; iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

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
          "--stop-timeout=30"
          "--cap-drop=ALL"
          "--cap-add=CHOWN"
          "--cap-add=DAC_OVERRIDE"
          "--cap-add=FOWNER"
          "--cap-add=SETUID"
          "--cap-add=SETGID"
          "--cap-add=KILL"
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
        # Health = tunnel is up.
        "--health-cmd=ip link show wg0 && wg show wg0"
        "--health-interval=30s"
        "--health-retries=3"
        "--health-on-failure=kill"
      ];
      podman.sdnotify = "healthy";

      labels = labels;
    };

    # podman-wireguard is gated on its tunnel healthcheck (sdnotify=healthy),
    # so dependsOn already guarantees the VPN is up before an arr container starts.
    # bindsTo/partOf additionally stop and restart the arr containers together with wireguard,
    # and the start limit keeps a broken stack from retrying forever and blocking nixos-rebuild switch.
    systemd.services = {
      podman-wireguard = {
        serviceConfig.TimeoutStartSec = lib.mkForce 120;
        startLimitIntervalSec = 600;
        startLimitBurst = 3;
      };
    }
    // builtins.listToAttrs (
      map (name: {
        name = "podman-${name}";
        value = {
          after = [ "ensure-container-dirs.service" ];
          bindsTo = [ "podman-wireguard.service" ];
          partOf = [ "podman-wireguard.service" ];
          startLimitIntervalSec = 600;
          startLimitBurst = 3;
        };
      }) (lib.attrNames cfg.services)
    );
  };
}
