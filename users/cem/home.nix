{ pkgs, user, home, ... }:

{
  imports = [ ../../modules/home-manager ];

  home = {
    username = user;
    homeDirectory = home;
  };

  home.file = {
  };

  home.packages = with pkgs; [ ];
}
