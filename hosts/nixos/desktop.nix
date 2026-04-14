{ pkgs, ... }:
{
  programs.firefox.enable = true;

  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # enable zsh and set it as default user shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    cifs-utils
    gcc
    linuxPackages.cpupower
    pix
    seahorse
  ];
}
