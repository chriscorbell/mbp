#!/bin/bash
# Shared hover-tooltip handler for sketchybar popups.
# Usage: hover.sh <item> [populate-cmd ...]
#   Called from an item's `script` when SENDER is mouse.entered / mouse.exited.
#   entered: after a 0.25s debounce (cancelled if the mouse leaves first) run the
#            optional populate-cmd, then show the popup.
#   exited:  hide the popup.
#   Items whose popup content is refreshed elsewhere pass no populate-cmd.
item="$1"; shift
MARK="/tmp/sketchybar_hover_${item}"
case "$SENDER" in
  mouse.entered)
    touch "$MARK"
    ( sleep 0.25
      [ -f "$MARK" ] || exit 0
      [ "$#" -gt 0 ] && "$@"
      sketchybar --set "$item" popup.drawing=on
    ) >/dev/null 2>&1 &
    disown 2>/dev/null ;;
  mouse.exited)
    rm -f "$MARK"
    sketchybar --set "$item" popup.drawing=off ;;
esac
