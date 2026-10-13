{ pkgs, ... }:
{
  # Shared by every Wayland compositor feature (hyprland, mango):
  # bar, audio, portals, polkit agent and the desktop utilities the keybinds use.

  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ../waybar
    ../lock-screen
    ./mic-toggle.nix
  ];

  # ============================================================================
  # SERVICES
  # ============================================================================
  services = {
    dbus.enable = true;

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

  # Password prompt for apps that ask for admin rights (polkit), started with
  # the graphical session of either compositor
  systemd.user.services.polkit-gnome-agent = {
    description = "polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  # ============================================================================
  # SECURITY
  # ============================================================================
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # ============================================================================
  # PACKAGES
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    waybar # Status bar
    dunst # Notification daemon

    blueman # Bluetooth manager

    # Screenshot and screen recording
    grim # Screenshot
    slurp # Region selector
    wl-clipboard # Clipboard utilities

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
