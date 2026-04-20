{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.homelab.containers;
  inherit (config.homelab) domain;

  vpnServiceNames = [
    "sabnzbd"
    "sonarr"
    "radarr"
    "seerr"
  ];

  waitForWireguardTunnel = pkgs.writeShellScript "wait-for-wireguard-tunnel" ''
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
  '';

  # All services behind wireguard share its network namespace
  vpnDependency = {
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
in
{
  # ==========================================================================
  # DIRECTORIES
  # ==========================================================================
  homelab.containers.requiredDirs = [
    { directory = "${cfg.configPath}/arr/wireguard/data/config"; }
    { directory = "${cfg.configPath}/arr/sabnzbd/data/config"; }
    { directory = "${cfg.configPath}/arr/sonarr/data/config"; }
    { directory = "${cfg.configPath}/arr/radarr/data/config"; }
    { directory = "${cfg.configPath}/arr/seerr/data/config"; }
    {
      directory = "${cfg.storagePath}";
      owner = "root";
      group = "root";
    }
    {
      directory = "${cfg.storagePath}/media/tv";
      owner = "root";
      group = "root";
    }
    {
      directory = "${cfg.storagePath}/media/movies";
      owner = "root";
      group = "root";
    }
    {
      directory = "${cfg.storagePath}/usenet/complete";
      owner = "root";
      group = "root";
    }
  ];

  # ==========================================================================
  # CONTAINERS
  # ==========================================================================
  virtualisation.oci-containers.containers = {

    # ========================================================================
    # WIREGUARD (VPN gateway for all media services)
    # ========================================================================
    wireguard = {
      image = "lscr.io/linuxserver/wireguard:latest";
      pull = "newer";
      hostname = "wireguard";
      networks = [
        cfg.networks.vpnEgress
        cfg.networks.vpnMedia
      ];

      environment = cfg.commonEnv // {
        "LOG_CONFS" = "true";
      };

      volumes = [
        "${cfg.configPath}/arr/wireguard/data/config:/config"
        "/run/booted-system/kernel-modules/lib/modules:/lib/modules:ro"
      ];

      capabilities = {
        net_admin = true;
        # sys_module = true;
        chown = true;
        dac_override = true;
        fowner = true;
        setuid = true;
        setgid = true;
      };

      # TODO: check if --cap-drop=ALL conflicts with
      # declaring individual capabilities in the capabilities attribute
      extraOptions = [
        "--cap-drop=ALL"
        # "--cap-add=NET_ADMIN"
        # "--cap-add=SYS_MODULE"
        # "--cap-add=CHOWN"
        # "--cap-add=DAC_OVERRIDE"
        # "--cap-add=FOWNER"
        # "--cap-add=SETUID"
        # "--cap-add=SETGID"
        "--security-opt=no-new-privileges"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
        "--dns=8.8.8.8"
      ];

      labels = {
        "traefik.enable" = "true";
        "traefik.docker.network" = cfg.networks.vpnMedia;

        # sabnzbd
        "traefik.http.routers.sabnzbd.rule" = "Host(`nzb.${domain}`)";
        "traefik.http.routers.sabnzbd.entrypoints" = "websecure";
        "traefik.http.routers.sabnzbd.tls.certresolver" = "letsencrypt";
        "traefik.http.routers.sabnzbd.middlewares" = "vpn-whitelist@file";
        "traefik.http.routers.sabnzbd.service" = "sabnzbd";
        "traefik.http.services.sabnzbd.loadbalancer.server.port" = "8080";

        # sonarr
        "traefik.http.routers.sonarr.rule" = "Host(`sonarr.${domain}`)";
        "traefik.http.routers.sonarr.entrypoints" = "websecure";
        "traefik.http.routers.sonarr.tls.certresolver" = "letsencrypt";
        "traefik.http.routers.sonarr.middlewares" = "vpn-whitelist@file";
        "traefik.http.routers.sonarr.service" = "sonarr";
        "traefik.http.services.sonarr.loadbalancer.server.port" = "8989";

        # radarr
        "traefik.http.routers.radarr.rule" = "Host(`radarr.${domain}`)";
        "traefik.http.routers.radarr.entrypoints" = "websecure";
        "traefik.http.routers.radarr.tls.certresolver" = "letsencrypt";
        "traefik.http.routers.radarr.middlewares" = "vpn-whitelist@file";
        "traefik.http.routers.radarr.service" = "radarr";
        "traefik.http.services.radarr.loadbalancer.server.port" = "7878";

        # seerr
        "traefik.http.routers.seerr.rule" = "Host(`seerr.${domain}`)";
        "traefik.http.routers.seerr.entrypoints" = "websecure";
        "traefik.http.routers.seerr.tls.certresolver" = "letsencrypt";
        "traefik.http.routers.seerr.middlewares" = "vpn-whitelist@file";
        "traefik.http.routers.seerr.service" = "seerr";
        "traefik.http.services.seerr.loadbalancer.server.port" = "5055";

        # --- UNCOMMENT TO ENABLE ---
        # # qbittorrent
        # "traefik.http.routers.qbittorrent.rule" = "Host(`qbittorrent.${domain}`)";
        # "traefik.http.routers.qbittorrent.entrypoints" = "websecure";
        # "traefik.http.routers.qbittorrent.tls.certresolver" = "letsencrypt";
        # "traefik.http.routers.qbittorrent.middlewares" = "vpn-whitelist@file";
        # "traefik.http.services.qbittorrent.loadbalancer.server.port" = "8084";

        # # jackett
        # "traefik.http.routers.jackett.rule" = "Host(`jackett.${domain}`)";
        # "traefik.http.routers.jackett.entrypoints" = "websecure";
        # "traefik.http.routers.jackett.tls.certresolver" = "letsencrypt";
        # "traefik.http.routers.jackett.middlewares" = "vpn-whitelist@file";
        # "traefik.http.services.jackett.loadbalancer.server.port" = "9117";
      };

    };

    # ========================================================================
    # SABNZBD (usenet downloader)
    # ========================================================================
    sabnzbd = {
      image = "lscr.io/linuxserver/sabnzbd:latest";
      pull = "newer";
      environment = cfg.commonEnv;

      volumes = [
        "${cfg.configPath}/arr/sabnzbd/data/config:/config"
        "${cfg.storagePath}:/data"
      ];
    }
    // vpnDependency;

    # ========================================================================
    # SONARR (tv shows)
    # ========================================================================
    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      pull = "newer";
      environment = cfg.commonEnv;

      volumes = [
        "${cfg.configPath}/arr/sonarr/data/config:/config"
        "${cfg.storagePath}:/data"
      ];
    }
    // vpnDependency;

    # ========================================================================
    # RADARR (movies)
    # ========================================================================
    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      pull = "newer";
      environment = cfg.commonEnv;

      volumes = [
        "${cfg.configPath}/arr/radarr/data/config:/config"
        "${cfg.storagePath}:/data"
      ];
    }
    // vpnDependency;

    # ========================================================================
    # seerr (media requests)
    # ========================================================================
    seerr = {
      image = "ghcr.io/seerr-team/seerr:latest";
      pull = "newer";
      environment = cfg.commonEnv;

      volumes = [
        "${cfg.configPath}/arr/seerr/data/config:/app/config"
      ];
    }
    // vpnDependency;

    # ========================================================================
    # DISABLED SERVICES
    # ========================================================================

    # --- QBITTORRENT ---
    # qbittorrent = {
    #   image = "lscr.io/linuxserver/qbittorrent:latest";
    #   pull = "newer";
    #   environment = cfg.commonEnv // {
    #     "WEBUI_PORT" = "8084";
    #   };
    #   volumes = [
    #     "${cfg.configPath}/arr/qbittorrent:/config"
    #     "${cfg.storagePath}:/data"
    #   ];
    # } // vpnDependency;

    # --- JACKETT ---
    # jackett = {
    #   image = "lscr.io/linuxserver/jackett:latest";
    #   pull = "newer";
    #   environment = cfg.commonEnv // {
    #     "AUTO_UPDATE" = "true";
    #   };
    #   volumes = [
    #     "${cfg.configPath}/arr/jackett:/config"
    #     "${cfg.storagePath}/torrents:/data"
    #   ];
    # } // vpnDependency;

    # --- READARR ---
    # readarr = {
    #   image = "lscr.io/linuxserver/readarr:nightly";
    #   pull = "newer";
    #   environment = cfg.commonEnv;
    #   volumes = [
    #     "${cfg.configPath}/arr/readarr:/config"
    #     "${cfg.storagePath}:/data"
    #   ];
    # } // vpnDependency;

    # --- LIDARR ---
    # lidarr = {
    #   image = "lscr.io/linuxserver/lidarr:latest";
    #   pull = "newer";
    #   environment = cfg.commonEnv;
    #   volumes = [
    #     "${cfg.configPath}/arr/lidarr:/config"
    #     "${cfg.storagePath}:/data"
    #   ];
    # } // vpnDependency;

    # --- BAZARR ---
    # bazarr = {
    #   image = "lscr.io/linuxserver/bazarr:latest";
    #   pull = "newer";
    #   environment = cfg.commonEnv;
    #   volumes = [
    #     "${cfg.configPath}/arr/bazarr:/config"
    #     "${cfg.storagePath}:/data"
    #   ];
    # } // vpnDependency;
  };

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
          ExecStartPre = [ waitForWireguardTunnel ];
          TimeoutStartSec = lib.mkForce "180";
        };
      };
    }) vpnServiceNames
  );
}
