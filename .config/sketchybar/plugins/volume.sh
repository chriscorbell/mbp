#!/bin/bash
# $INFO holds the new volume % on volume_change; fall back to a query otherwise.
VOL="$INFO"
[ -z "$VOL" ] && VOL="$(osascript -e 'output volume of (get volume settings)')"

case "$VOL" in
  0)                  ICON="󰖁" ;;
  [1-9]|[1-2][0-9])   ICON="󰕿" ;;
  [3-5][0-9])         ICON="󰖀" ;;
  *)                  ICON="󰕾" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="${VOL}%"
