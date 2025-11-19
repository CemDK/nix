{ pkgs, ... }: {

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [ ../waybar ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services.dbus.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # XDG portal for screen sharing, file picker, etc. (required for Wayland)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ============================================================================
  # SECURITY
  # ============================================================================
  security.rtkit.enable = true;

  # ============================================================================
  # SECURITY
  # ============================================================================
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # ============================================================================
  # PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Terminal
    kitty # just in case

    # Wayland utilities
    waybar # Status bar
    rofi # App launcher
    dunst # Notification daemon
    hyprpaper # Wallpaper daemon
    # wlr-randr # Wayland display configuration tool (for resolution)

    blueberry

    # Screenshot and screen recording
    # grim # Screenshot
    # slurp # Region selector
    # wl-clipboard # Clipboard utilities

    # File manager
    # xfce.thunar

    # Basic utilities
    brightnessctl # Brightness control
    networkmanagerapplet
    pavucontrol # Audio control
  ];
}
