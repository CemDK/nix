{ pkgs, ... }:
{
  imports = [ ../wayland-desktop ];

  # use newer mangowc from unstable nixpkgs
  programs.mangowc = {
    enable = true;
    package = pkgs.unstable.mangowc;
  };

  environment.systemPackages = with pkgs; [
    swaybg # for the wallpaper
    wlr-randr # Monitor info / modes
  ];
}
