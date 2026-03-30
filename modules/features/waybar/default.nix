{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # waybar dependencies
    blueman # bluetooth gui
    brightnessctl # keyboard brightness controls
    pavucontrol # audio controls gui
    playerctl # media control
    pulseaudio
  ];

  services.blueman.enable = true;
}
