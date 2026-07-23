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
        hyprshutdown -t "Restarting..." --post-cmd "systemctl reboot"
        ;;
    Shutdown)
        hyprshutdown -t "Shutting down..." --post-cmd "systemctl poweroff"
        ;;
    Logout)
        hyprshutdown -t "Logging out..."
        ;;
esac
