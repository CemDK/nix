{
  inputs,
  pkgs,
  self,
  ...
}:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  home-manager.sharedModules = [ "${self}/modules/home/walker" ];

  programs.firefox.enable = true;

  programs.nix-ld.enable = true;

  fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];

  # enable zsh and set it as default user shell
  programs.zsh.enable = true;
  # home-manager runs compinit already; a second run in /etc/zshrc costs ~120ms per shell.
  # But enableCompletion also linked /share/zsh into the system profile, which running
  # shells rely on to (re)load compinit — keep the link without the compinit run.
  programs.zsh.enableCompletion = false;
  environment.pathsToLink = [ "/share/zsh" ];
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    cifs-utils
    gcc
    linuxPackages.cpupower
    pix
    seahorse
  ];
}
