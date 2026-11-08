#!/usr/bin/env bash

options="Shutdown\nReboot\nSuspend\nLock\nLogout"

choice=$(echo -e "$options" | \
    wofi --dmenu \
    --prompt="Power" \
    --sort-order=default \
    --cache-file=/dev/null)

case "$choice" in
    Lock)
        hyprlock
        ;;
    Suspend)
        systemctl suspend
        ;;
    Reboot)
        hyprshutdown --no-exit --no-fork -t "Restarting..." && systemctl reboot
        ;;
    Shutdown)
        hyprshutdown --no-exit --no-fork -t "Shutting down..." && systemctl poweroff
        ;;
    Logout)
        hyprshutdown -t "Logging out..."
        ;;
esac
