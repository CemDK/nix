#!/usr/bin/env bash

# System menu using walker --dmenu, inspired by omarchy
options="Lock\nSuspend\nLogout\nReboot\nShutdown"

choice=$(echo -e "$options" | walker --dmenu --width 200 --minheight 1 --maxheight 300 -p "System...")

case "$choice" in
  *Lock*) hyprlock ;;
  *Suspend*) systemctl suspend ;;
  *Logout*) uwsm stop ;;
  *Reboot*) systemctl reboot ;;
  *Shutdown*) systemctl poweroff ;;
esac
