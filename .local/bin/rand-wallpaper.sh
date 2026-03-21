#!/usr/bin/env bash

if [[ `pgrep -f $0` != "$$" ]]; then
        echo "Another instance already exist! Exiting"
        exit
fi

# Wallpaper directory
WP_FOLDER=~/.config/omarchy/current/theme/backgrounds/

# Time in seconds to change wallpaper
WAIT_TIME=299

# Kill any existing instances
killall -9 swaybg

# Get initial file and start
FILE=$(find "$WP_FOLDER" -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n1)
swaybg -i "$FILE" -m fill &
CURRENT_PID=$!

while true; do
    sleep "$WAIT_TIME"
    
    # Get new wallpaper
    FILE=$(find "$WP_FOLDER" -type f \( -name '*.png' -o -name '*.jpg' \) | shuf -n1)
    
    # Start new instance
    swaybg -i "$FILE" -m fill &
    NEW_PID=$!
    
    # Small delay to ensure new wallpaper is loaded
    sleep 1
    
    # Kill previous instance
    kill $CURRENT_PID 2>/dev/null
    
    # Update PID
    CURRENT_PID=$NEW_PID
done
