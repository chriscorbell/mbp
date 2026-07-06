#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

case "$SENDER" in
  mouse.entered|mouse.exited)
    exec "$HOME/.config/sketchybar/helpers/hover.sh" "$NAME" \
         "$HOME/.config/sketchybar/plugins/procs.sh" cpu ;;
esac

# user+sys CPU from top's summary line.
CPU="$(top -l 1 -n 0 | awk -F'[ %]+' '/CPU usage/{printf "%d", $3+$5}')"
[ -z "$CPU" ] && exit 0

if   [ "$CPU" -ge 80 ]; then COLOR="$RED"
elif [ "$CPU" -ge 50 ]; then COLOR="$PEACH"
else COLOR="$GREEN"; fi

sketchybar --set "$NAME" icon.color="$COLOR" label="${CPU}%"
