{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # waybar dependencies 
    blueberry # bluetooth gui
    brightnessctl # keyboard brightness controls
    pavucontrol # audio controls gui
    playerctl # media control
    pulseaudio
  ];
}
