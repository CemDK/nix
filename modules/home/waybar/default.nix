{ pkgs, ... }: {
  # waybar dependencies 
  home.packages = with pkgs; [
    blueberry
    pulseaudio
    brightnessctl
    pavucontrol

  ];
}
