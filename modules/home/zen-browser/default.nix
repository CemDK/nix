{ pkgs, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "zen-browser";
  version = "1.17.6b";

  src = fetchurl {
    url =
      "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
    sha256 = "1kmcs1clzw6wz9l90mvbp6fdpgj49f723q52pf6l194ziwjb0ir2";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    glib
    gtk3
    dbus
    nss
    nspr
    alsa-lib
  ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/zen-browser

    cp -r * $out/lib/zen-browser/

    ln -s $out/lib/zen-browser/zen $out/bin/zen-browser
  '';

  meta = with lib; {
    description =
      "Zen Browser - A Firefox-based browser focused on privacy and customization";
    homepage = "https://zen-browser.app";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}

