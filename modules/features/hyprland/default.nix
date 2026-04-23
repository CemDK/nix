{ pkgs, ... }:
{

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [ ../waybar ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    dbus.enable = true;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''
            ${pkgs.tuigreet}/bin/tuigreet --greeting 'SHOKUNIX' --asterisks --remember
                    --remember-user-session --time --cmd 'uwsm start hyprland-uwsm.desktop' '';
          user = "greeter";
        };
        initial_session = {
          command = "uwsm start hyprland-uwsm.desktop";
          user = "cemdk";
        };
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
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
  # ENVIRONMENT VARIABLES
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

    blueman # Bluetooth manager

    # Screenshot and screen recording
    # grim # Screenshot
    # slurp # Region selector
    # wl-clipboard # Clipboard utilities

    # File manager
    # xfce.thunar

    # Basic utilities
    brightnessctl
    swayosd
    networkmanagerapplet
    pavucontrol # Audio control
    nautilus # File manager

    # cursors
    rose-pine-cursor
  ];
}
