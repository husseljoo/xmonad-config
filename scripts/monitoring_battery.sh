#!/bin/bash

# Threshold battery level
THRESHOLD=30

IMAGE_PATH="$HOME/.config/dunst/images/battery-low.png"

while true; do
    # Get battery level (using acpi)
    BATTERY_LEVEL=$(acpi -b | grep -oP '\d+(?=%)')

    # Check if battery level is below the threshold
    if [[ "$BATTERY_LEVEL" -lt "$THRESHOLD" ]]; then
        notify-send -t 0 -i "$IMAGE_PATH" "Battery Low" "Battery level is at $BATTERY_LEVEL%.\nCharge your laptop Broski."
    fi

    # Sleep for 5 minutes before checking again
    sleep 300
done
