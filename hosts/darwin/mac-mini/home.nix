{ pkgs, ... }: {

  imports = [
    ../../../modules/home
    # ../../../modules/home/...
  ];

  home = {
    packages = with pkgs;
      [
        #
        localsend
      ];

    file = { };
  };
}

