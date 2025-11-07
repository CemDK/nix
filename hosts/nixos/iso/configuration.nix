{ pkgs, lib, ... }: {

  environment.etc."shokunix".source = ../../..;

  # reduce build time with faster compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # ============================================================================
  # NIX CONFIGURATION
  # ============================================================================
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = "experimental-features = nix-command flakes";

  # ============================================================================
  # BOOTLOADER
  # ============================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.supportedFilesystems =
    lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  # systemd = {
  #   services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  #   targets = {
  #     sleep.enable = false;
  #     suspend.enable = false;
  #     hibernate.enable = false;
  #     hybrid-sleep.enable = false;
  #   };
  # };
  #
  # users.extraUsers.root.initialPassword = "nixos";

  # ============================================================================
  # SYSTEM PACKAGES FOR THE ISO
  # ============================================================================
  environment.systemPackages = with pkgs; [
    gum
    networkmanagerapplet
    #impala # TUI for managing wifi

    (pkgs.writeShellScriptBin "shokunix_installer"
      (builtins.readFile ./shokunix_installer))
  ];

  # ============================================================================
  # HARDWARE
  # ============================================================================
  # Enable TPlink Archer Nano WiFi dongle (needed for installation)
  # boot.extraModulePackages = [ config.boot.kernelPackages.rtl88xxau-aircrack ];

  # Include all firmware
  # for the ISO to recognize wifi hardware
  # hardware.enableAllFirmware = true;
  # hardware.enableRedistributableFirmware = true;

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  networking.wireless.enable = lib.mkForce false;
  networking.networkmanager.enable = true;
  networking.hostName = "nixos";
  #networking.wireless.iwd.enable = true; # impala dependency

  # ============================================================================
  # LOCALIZATION & TIMEZONE
  # ============================================================================
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # ============================================================================
  # INPUT & KEYBOARD
  # ============================================================================
  services.xserver.xkb = {
    layout = lib.mkDefault "us";
    variant = "";
  };
}
