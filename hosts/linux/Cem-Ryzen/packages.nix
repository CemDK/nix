{ pkgs, ... }:
{

  # ============================================================================
  # PACKAGES
  # ============================================================================
  # INFO: everything in ./linux is managed via home-manager
  # so we only add packages to home.packages
  # neither environment.systemPackages = ...
  # nor users.users.<username>.packages = ...
  # are used here

  # Add home-manager packages here
  # This installs into $HOME/.nix-profile
  home.packages = with pkgs; [
    # Development tools
    minio-client
    redis
    stripe-cli
    dioxus-cli
    ngrok
    bun
    pastel
    opencode

    # Sandboxing related
    socat
    bubblewrap

    # Stuff
    # miktex
    conda
    fastfetch
    google-cloud-sdk
    iperf3
    mkvtoolnix-cli
    spotdl
    yt-dlp

    # TODO: look into making this work nicely
    # use this to mount a remote filesystem on my VPS via SSH
    fuse
    sshfs

    chromium
    uv
    esphome
  ];

}
