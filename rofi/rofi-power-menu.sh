#!/bin/bash
# rofi-power-menu.sh
# A simple Rofi power menu for Hyprland

# Options
OPTIONS=" Shutdown\n Reboot\n Lock\n Suspend\n Logout"

# Ask using Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power")

# Execute choice
case "$CHOICE" in
    " Shutdown")
        systemctl poweroff
        ;;
    " Reboot")
        systemctl reboot
        ;;
    " Lock")
        hyprctl dispatch lock
        ;;
    " Suspend")
        systemctl suspend
        ;;
    " Logout")
        hyprctl dispatch exit
        ;;
esac
