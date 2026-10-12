{ pkgs, ... }:
let
  # workaround because pulsectl-rs 0.3.2 (swayosd 0.3.1) used by swayosd
  # `--input-volume mute-toggle` correctly gets the *source* id, but mutes
  # the *sink* with that id or silently fails
  # fixed in swayosd 0.3.2
  mic-toggle = pkgs.writeShellScriptBin "mic-toggle" ''
    ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    if ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | ${pkgs.gnugrep}/bin/grep -q MUTED; then
      ${pkgs.swayosd}/bin/swayosd-client --custom-icon microphone-sensitivity-muted-symbolic --custom-message "Mic muted"
    else
      ${pkgs.swayosd}/bin/swayosd-client --custom-icon microphone-sensitivity-high-symbolic --custom-message "Mic on"
    fi
  '';
in
{
  environment.systemPackages = [ mic-toggle ];
}
