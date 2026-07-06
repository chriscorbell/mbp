#!/bin/bash
# Toggle/refresh a `caffeinate` keep-awake. Native replacement for Caffeine.
source "$HOME/.config/sketchybar/colors.sh"

if [ "$1" = "toggle" ]; then
  if pgrep -x caffeinate >/dev/null; then
    killall caffeinate
  else
    nohup caffeinate -d >/dev/null 2>&1 &
  fi
fi

if pgrep -x caffeinate >/dev/null; then
  sketchybar --set "${NAME:-caffeine}" icon="󰅶" icon.color="$YELLOW"      # awake: filled cup
else
  sketchybar --set "${NAME:-caffeine}" icon="󰾪" icon.color="$SUBTEXT"     # normal: coffee-off
fi
