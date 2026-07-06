#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

case "$SENDER" in
  mouse.entered|mouse.exited)
    exec "$HOME/.config/sketchybar/helpers/hover.sh" "$NAME" ;;
esac

BATT="$(pmset -g batt)"
PCT="$(echo "$BATT" | grep -Eo '[0-9]+%' | tr -d '%')"
[ -z "$PCT" ] && exit 0
CHARGING="$(echo "$BATT" | grep -o 'AC Power')"

if [ -n "$CHARGING" ]; then
  ICON="󰂄" ; COLOR="$GREEN"
else
  case "$PCT" in
    100|9[0-9]|8[0-9]|7[0-9]) ICON="󰂁" ; COLOR="$GREEN" ;;
    6[0-9]|5[0-9]|4[0-9])     ICON="󰁿" ; COLOR="$YELLOW" ;;
    3[0-9]|2[0-9])            ICON="󰁽" ; COLOR="$PEACH" ;;
    *)                        ICON="󰁻" ; COLOR="$RED" ;;
  esac
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PCT}%"

# Popup detail: time remaining (or charge state)
REMAIN="$(echo "$BATT" | grep -Eo '[0-9]+:[0-9]+ remaining' | head -1)"
if [ -n "$CHARGING" ]; then DETAIL="Charging"
elif [ -n "$REMAIN" ]; then DETAIL="$REMAIN"
else DETAIL="Calculating…"; fi
sketchybar --set battery.detail label="$DETAIL" 2>/dev/null
