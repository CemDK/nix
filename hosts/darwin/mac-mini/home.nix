{ self, config, ... }:
{
  imports = [
    "${self}/modules/home"
  ];

  home.stateVersion = "25.05";

  programs.desktoppr = {
    enable = true;
    settings.picture = "${config.home.homeDirectory}/.config/wallpapers/oat/autumn-leaves-3.png";
  };
}
