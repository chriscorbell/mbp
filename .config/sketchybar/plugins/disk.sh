#!/bin/bash
# Free space on the boot volume, color-coded by how full it is.
source "$HOME/.config/sketchybar/colors.sh"

read -r USE AVAIL < <(df -H / | awk 'NR==2{gsub("%","",$5); print $5, $4}')
[ -z "$USE" ] && exit 0

if   [ "$USE" -ge 90 ]; then COLOR="$RED"
elif [ "$USE" -ge 75 ]; then COLOR="$PEACH"
else COLOR="$GREEN"; fi

sketchybar --set "$NAME" icon.color="$COLOR" label="$AVAIL"
