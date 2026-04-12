{ self, ... }:
{
  imports = [
    "${self}/modules/home"
  ];

  home.stateVersion = "25.05";
}
