{ pkgs, ... }: {

  imports = [
    ../../../modules/home
    # ../../../modules/home/...
  ];

  # Packages specific to this machine go here
  home = {
    packages = with pkgs;
      [
        #
        localsend
      ];
  };
}

