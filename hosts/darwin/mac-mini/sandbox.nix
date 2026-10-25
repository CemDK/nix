{
  config,
  pkgs,
  ...
}:
let
  inherit (config.common) user home;

  name = "sandbox";
  account = "cembox"; # "sandbox" is an alias of the built-in _sandbox (uid 60)
  uid = 550;
  anchor = "com.apple/${name}"; # evaluated by the stock `anchor "com.apple/*"` in /etc/pf.conf
  flag = "/var/db/${name}-online"; # holds the epoch until which online mode lasts

  # Loopback, LAN, tailnet and link-local stay blocked even in online mode.
  lanRules = pkgs.writeText "${name}-lan.pf" ''
    block drop out quick proto { tcp udp } to { 127.0.0.0/8 ::1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 100.64.0.0/10 169.254.0.0/16 fc00::/7 fe80::/10 } user ${toString uid}
  '';
  offlineRules = pkgs.writeText "${name}-offline.pf" ''
    block drop out quick proto { tcp udp } user ${toString uid}
  '';

  sandbox-net = pkgs.writeShellScriptBin "sandbox-net" ''
    set -eu
    apply() {
      /sbin/pfctl -q -e 2>/dev/null || true
      if [ -f ${flag} ] && [ "$(cat ${flag})" -gt "$(date +%s)" ]; then
        /sbin/pfctl -q -a ${anchor} -f ${lanRules}
      else
        rm -f ${flag}
        /sbin/pfctl -q -a ${anchor} -f ${offlineRules}
      fi
    }
    case "''${1:-status}" in
      apply) apply ;;
      online)
        echo $(( $(date +%s) + ''${2:-30} * 60 )) > ${flag}
        apply
        echo "${name}: internet on for ''${2:-30} min (LAN/tailnet stay blocked)"
        ;;
      offline)
        rm -f ${flag}
        apply
        echo "${name}: offline"
        ;;
      status) /sbin/pfctl -a ${anchor} -s rules 2>/dev/null ;;
      *) echo "usage: sudo sandbox-net [online [minutes]|offline|status]" >&2; exit 1 ;;
    esac
  '';
in
{
  # ============================================================================
  # CEMBOX USER (runs untrusted code, no network)
  # ============================================================================
  users.knownUsers = [ account ];
  users.users.${account} = {
    inherit uid;
    description = "Cembox";
    home = "/Users/${account}";
    createHome = true;
    isHidden = false; # visible in the login window for GUI sessions
    shell = pkgs.zsh;
    packages = with pkgs; [
      git
      zstd
      lz4
      spirv-cross
      dotnet-sdk_10
      (python3.withPackages (
        ps: with ps; [
          backports-zstd # stdlib compression.zstd only from Python 3.14
          capstone
          fonttools
          lz4
        ]
      ))
    ];
  };

  # The sandbox user must not reach the root nix-daemon, which fetches URLs on its behalf.
  nix.settings.allowed-users = [
    "root"
    user
  ];

  environment.systemPackages = [ sandbox-net ];

  # Built .NET apps (apphost) look for the runtime here; nix's dotnet wrapper only covers `dotnet` itself.
  environment.etc."dotnet/install_location".text = "${pkgs.dotnet-sdk_10}/share/dotnet\n";

  # Re-applied every minute: pf.conf reloads and macOS updates can drop the anchor.
  launchd.daemons."${name}-net".serviceConfig = {
    ProgramArguments = [
      "${sandbox-net}/bin/sandbox-net"
      "apply"
    ];
    RunAtLoad = true;
    StartInterval = 60;
  };

  # Every local account is in `staff`; the default 750 home would be readable by the sandbox user.
  # Screen Sharing is limited to admins; cembox needs it for GUI/Metal sessions.
  system.activationScripts.postActivation.text = ''
    chmod 700 ${home}
    dseditgroup -o edit -a ${account} -t user com.apple.access_screensharing
  '';
}
