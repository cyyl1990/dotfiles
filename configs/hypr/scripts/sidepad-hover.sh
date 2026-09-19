#!/usr/bin/env bash

SIDEPAD_SCRIPT="$HOME/.config/hypr/scripts/sidepad-spawn"
SIDEPAD_CLASS="dotfiles-sidepad"

EDGE_WIDTH=40
TOP_GAP=100
BOTTOM_GAP=100

COOLDOWN=0.4
last_trigger=0

while true; do

    read X Y <<< $(hyprctl cursorpos | tr -d ',')

    MONITOR_HEIGHT=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .height')

    now=$(date +%s.%N)

    # chỉ kích hoạt khi chuột trong vùng sidepad
    if [ "$X" -le "$EDGE_WIDTH" ] && \
       [ "$Y" -ge "$TOP_GAP" ] && \
       [ "$Y" -le "$((MONITOR_HEIGHT - BOTTOM_GAP))" ]; then

        WINDOW_X=$(hyprctl clients -j | jq -r \
        --arg class "$SIDEPAD_CLASS" \
        '.[] | select(.class==$class) | .at[0]')

        if [ ! -z "$WINDOW_X" ] && [ "$WINDOW_X" -lt 0 ]; then

            if (( $(echo "$now - $last_trigger > $COOLDOWN" | bc -l) )); then
                "$SIDEPAD_SCRIPT"
                last_trigger=$now
            fi
        fi
    fi

    sleep 0.05
done
