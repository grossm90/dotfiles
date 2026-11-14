#!/usr/bin/env bash
#
# Applies battery or AC settings at login, then again whenever the charger
# is plugged in or unplugged.
#
#   on battery: system76-power "battery" profile, screen at 48 Hz
#   on AC:      system76-power "balanced" profile, screen at 60 Hz
#
# Started from hyprland.lua. The monitor values below must match the
# hl.monitor() block in hyprland.lua, which applies the same rule whenever
# the config is loaded or reloaded.

MONITOR="eDP-1"
RESOLUTION="1920x1200"
SCALE="1.2"
BATTERY_STATUS="/sys/class/power_supply/BAT0/status"

last=""

apply() {
    local state profile hz

    if [[ "$(cat "$BATTERY_STATUS" 2>/dev/null)" == "Discharging" ]]; then
        state="battery" profile="battery" hz="48"
    else
        state="ac" profile="balanced" hz="60"
    fi

    # only act when the state actually changes, so a profile picked by hand
    # sticks until the charger is next plugged in or unplugged
    [[ "$state" == "$last" ]] && return
    last="$state"

    system76-power profile "$profile"
    hyprctl eval "hl.monitor({ output = \"$MONITOR\", mode = \"${RESOLUTION}@${hz}\", position = \"auto\", scale = $SCALE })" >/dev/null
}

apply

udevadm monitor --udev --subsystem-match=power_supply | while true; do
    # wake on a power event, or every 60 s as a safety net
    read -r -t 60 _
    rc=$?
    if (( rc == 0 )); then
        # let the burst of events finish and the battery status settle
        while read -r -t 1 _; do :; done
    elif (( rc <= 128 )); then
        # udevadm exited
        exit 1
    fi
    apply
done
