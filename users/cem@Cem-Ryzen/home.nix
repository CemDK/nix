{ pkgs, user, home, ... }:

{
  imports = [ ../../modules/home-manager/default.nix ];

  # TODO: re-evaluate if these are necessary
  systemd.user.startServices = "sd-switch";
  # WSL-specific settings
  # home.sessionVariables = {
  #   DISPLAY = "$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0";
  #   LIBGL_ALWAYS_INDIRECT = "1";
  # };

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = { };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Development tools
    stripe-cli
    claude-code
    redis
    minio-client
    eslint

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

    typescript-go
    vscode-langservers-extracted
    tailwindcss-language-server
    yaml-language-server
    terraform-ls
    docker-language-server
    dockerfile-language-server
    typescript-language-server

    bash-language-server

    # helm-ls

    # NVIM lsp stuff seems to use libuv-watchdirs, but this makes nvim rather slow when opening
    # installing inotify-tools seems to fix this
    #  File watch backend: libuv-watchdirs
    #  ⚠️ WARNING libuv-watchdirs has known performance issues. Consider installing inotify-tools.
    inotify-tools

    # python313
    # python313Packages.torch
    # python313Packages.torchaudio
    # python313Packages.torchvision

  ];
}
