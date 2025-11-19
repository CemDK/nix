{ pkgs, ... }: {

  imports = [
    ../../../modules/home
    ../../../modules/home/retroarch
    #
  ];

  home = {
    packages = with pkgs; [
      # local apps
      claude-code
      localsend
      obs-studio
    ];

    file = { };
  };
}

