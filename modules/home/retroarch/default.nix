{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (retroarch-full.withCores (
      cores: with cores; [
        # Nintendo
        mgba
        dolphin
        mupen64plus
      ]
    ))

    # controller drivers
    udev
    # evtest
    libxkbcommon
    # xboxdrv - has been dropped, superseded by in-tree kernel driver
  ];
}
