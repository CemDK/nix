#!/usr/bin/env bash

# System menu using walker --dmenu, inspired by omarchy
# Same actions as the waybar snowflake menu (system-action, modules/features/waybar/system-menu.nix)
options="About\nLock\nSuspend\nLogout\nReboot\nShutdown"

choice=$(echo -e "$options" | walker --dmenu --width 200 --minheight 1 --maxheight 300 -p "System...")

case "$choice" in
  *About*) system-action about ;;
  *Lock*) system-action lock ;;
  *Suspend*) system-action suspend ;;
  *Logout*) system-action logout ;;
  *Reboot*) system-action reboot ;;
  *Shutdown*) system-action poweroff ;;
esac
