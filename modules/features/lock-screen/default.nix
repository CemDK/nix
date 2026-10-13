{ pkgs, ... }:
let
  # hyprlock reads logind's PreparingForSleep before it starts the fingerprint
  # scan. Right after login that reply can land in sd-bus's queue without the
  # socket becoming readable again, and hyprlock only drains the queue on
  # POLLIN, so the scan never starts. Drain it on every loop iteration instead.
  hyprlock = pkgs.hyprlock.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/core/hyprlock.cpp \
        --replace-fail "if (pollfds[1].revents & POLLIN /* dbus */) {" "if (dbusConn) {"
    '';
  });

  # Wallpaper with the blurred center column of the sddm-astronaut theme
  # (form width = screen width / 2.5), pre-rendered for 1920x1080
  background =
    pkgs.runCommand "lock-screen-background.png" { nativeBuildInputs = [ pkgs.imagemagick ]; }
      ''
        magick ${../../../dotfiles/wallpapers/oat/autumn-season-leafs-plant-scene-generative-ai.jpg} \
          -resize 1920x1080^ -gravity center -extent 1920x1080 base.png
        magick base.png -gravity center -crop 768x1080+0+0 +repage \
          -virtual-pixel edge -blur 0x30 column.png
        magick base.png column.png -gravity center -composite $out
      '';

  # Config: dotfiles/hypr/hyprlock.conf
  # --immediate-render locks right away instead of loading the background first,
  # so the desktop doesn't show while hyprlock starts.
  lock-screen = pkgs.writeShellScriptBin "lock-screen" ''
    exec ${hyprlock}/bin/hyprlock --immediate-render
  '';

  # Locks only sessions that SDDM started without a password, so a manual
  # login from the greeter (after logging out) doesn't ask twice
  login-lock = pkgs.writeShellScriptBin "login-lock" ''
    service=$(loginctl show-session "$XDG_SESSION_ID" -p Service --value)
    [ "$service" = sddm-autologin ] || exit 0
    exec ${lock-screen}/bin/lock-screen
  '';
in
{
  programs.hyprlock = {
    enable = true;
    package = hyprlock;
  };
  # Layout lives in dotfiles/hypr/hyprlock.conf, so tweaks apply without a rebuild
  environment.etc."lock-screen/background.png".source = background;

  # hyprlock talks to fprintd itself, in parallel with the password field.
  # pam_fprintd in its PAM stack would block the password until the scan times out.
  security.pam.services.hyprlock.fprintAuth = false;

  environment.systemPackages = [
    lock-screen
    login-lock
  ];
}
