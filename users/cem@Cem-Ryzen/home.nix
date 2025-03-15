{ pkgs, user, home, ... }:

{
  imports = [ ../../modules/home-manager/default.nix ];

  # TODO: re-evaluate if these are necessary
  systemd.user.startServices = "sd-switch";
  # WSL-specific settings
  # home.sessionVariables = {
  #   DISPLAY = "$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0";
  #   LIBGL_ALWAYS_INDIRECT = "1";
  # };

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = {
  };

  home.packages = with pkgs; [ ];
}
