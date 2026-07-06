#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

case "$SENDER" in
  mouse.entered|mouse.exited)
    exec "$HOME/.config/sketchybar/helpers/hover.sh" "$NAME" \
         "$HOME/.config/sketchybar/plugins/procs.sh" mem ;;
esac

TOTAL=$(sysctl -n hw.memsize)
PAGE=$(vm_stat | sed -n 's/.*page size of \([0-9]*\) bytes.*/\1/p')
read -r A W C < <(vm_stat | awk '
  /Pages active/            {gsub("\\.","",$3); a=$3}
  /Pages wired down/        {gsub("\\.","",$4); w=$4}
  /occupied by compressor/  {gsub("\\.","",$5); c=$5}
  END {print a, w, c}')

USED=$(( (A + W + C) * PAGE ))
PCT=$(( USED * 100 / TOTAL ))

if   [ "$PCT" -ge 85 ]; then COLOR="$RED"
elif [ "$PCT" -ge 65 ]; then COLOR="$PEACH"
else COLOR="$GREEN"; fi

sketchybar --set "$NAME" icon.color="$COLOR" label="${PCT}%"
