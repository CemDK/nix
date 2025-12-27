{ pkgs, lib, inputs, user, home, ... }:

{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    # Import custom modules
    ../../../modules/home
  ];

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nixpkgs.config.allowUnfree = true;
  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    # "home-manager=${inputs.home-manager}"
  ];

  # ============================================================================
  # SERVICES
  # ============================================================================
  # “When I run home-manager switch, ask systemd --user to
  # start/stop/restart services using systemd-native logic,
  # instead of manually killing and restarting them.”
  systemd.user.startServices = "sd-switch";

  # ============================================================================
  # PACKAGES
  # ============================================================================
  home = {
    stateVersion = lib.mkForce "21.11";
    packages = with pkgs; [
      # Development tools
      stripe-cli
      claude-code
      redis
      minio-client

      # Stuff
      iperf3
      mkvtoolnix-cli
      conda
      google-cloud-sdk
      miktex
      spotdl
      yt-dlp

      # TODO: look into making this work nicely
      # use this to mount a remote filesystem on my VPS via SSH
      sshfs
      fuse
    ];

    file = { };
  };
}
