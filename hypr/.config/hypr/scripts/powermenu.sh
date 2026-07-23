#!/usr/bin/env bash

options="Lock\nSuspend\nReboot\nShutdown\nLogout"

choice=$(echo -e "$options" | wofi --dmenu --prompt="Power")

case "$choice" in
  Lock)
    hyprlock
    ;;
  Suspend)
    systemctl suspend
    ;;
  Reboot)
    systemctl reboot
    ;;
  Shutdown)
    systemctl poweroff
    ;;
  Logout)
    hyprctl dispatch exit
    ;;
esac
