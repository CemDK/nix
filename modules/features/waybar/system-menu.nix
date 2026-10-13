{ pkgs, ... }:
let
  # Actions for the waybar system menu (dotfiles/waybar/system-menu.xml) and
  # scripts/system-menu.sh. Works under both Hyprland and mango.
  system-action = pkgs.writeShellScriptBin "system-action" ''
    case "$1" in
      about)
        exec ${pkgs.alacritty}/bin/alacritty --class about-this-computer --title "About This Computer" \
          --hold -e ${pkgs.fastfetch}/bin/fastfetch
        ;;
      lock)
        exec lock-screen # modules/features/lock-screen
        ;;
      logout)
        case "$XDG_CURRENT_DESKTOP" in
          *Hyprland*)
            ${pkgs.uwsm}/bin/uwsm check is-active && exec ${pkgs.uwsm}/bin/uwsm stop
            exec hyprctl dispatch exit
            ;;
          *mango*) exec mmsg dispatch quit ;;
          *) exec loginctl terminate-session "$XDG_SESSION_ID" ;;
        esac
        ;;
      suspend) exec systemctl suspend ;;
      reboot) exec systemctl reboot ;;
      poweroff) exec systemctl poweroff ;;
      *)
        echo "usage: system-action about|lock|logout|suspend|reboot|poweroff" >&2
        exit 1
        ;;
    esac
  '';
in
{
  environment.systemPackages = [
    system-action
    pkgs.fastfetch
    pkgs.nixos-icons # snowflake on the menu button (dotfiles/waybar/style.css)
  ];
}
