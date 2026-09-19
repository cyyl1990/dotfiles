#!/usr/bin/env bash

SIDEPAD_CLASS="dotfiles-sidepad"
SIDEPAD_SCRIPT="$HOME/.config/hypr/scripts/sidepad-spawn"

while true; do

    CURRENT_CLASS=$(hyprctl activewindow -j | jq -r ".class")

    if [ "$CURRENT_CLASS" != "$SIDEPAD_CLASS" ]; then

        WINDOW_X=$(hyprctl clients -j | jq -r \
        --arg class "$SIDEPAD_CLASS" \
        '.[] | select(.class==$class) | .at[0]')

        if [ ! -z "$WINDOW_X" ] && [ "$WINDOW_X" -ge 0 ]; then
            sleep 0.15
            "$SIDEPAD_SCRIPT" --hide
        fi

    fi

    sleep 0.2
done
