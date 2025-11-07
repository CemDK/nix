{ config, pkgs, lib, ... }: {

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.dbus.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # XDG portal for screen sharing, file picker, etc. (required for Wayland)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Essential desktop packages
  environment.systemPackages = with pkgs; [
    # Terminal
    kitty
    #foot
    # alacritty

    # Wayland utilities
    waybar # Status bar
    # wofi # Application launcher
    rofi-wayland
    dunst # Notification daemon
    # swww # Wallpaper daemon
    hyprpaper
    wlr-randr # Wayland display configuration tool (for resolution)

    # Screenshot and screen recording
    # grim # Screenshot
    # slurp # Region selector
    # wl-clipboard # Clipboard utilities

    # File manager
    # xfce.thunar

    # Basic utilities
    # networkmanagerapplet
    # pavucontrol # Audio control
    # brightnessctl # Brightness control
  ];

}
