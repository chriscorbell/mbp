#!/bin/bash
# Media control for the active Spotify/Music player. $1 = playpause|next|previous
action="$1"

for app in Spotify Music; do
  [ "$(osascript -e "application \"$app\" is running" 2>/dev/null)" != "true" ] && continue
  state=$(osascript -e "tell application \"$app\" to player state" 2>/dev/null)
  { [ -z "$state" ] || [ "$state" = "stopped" ]; } && continue
  case "$action" in
    playpause) osascript -e "tell application \"$app\" to playpause" ;;
    next)      osascript -e "tell application \"$app\" to next track" ;;
    previous)  osascript -e "tell application \"$app\" to previous track" ;;
  esac
  break
done

# Reflect the change immediately
"$HOME/.config/sketchybar/plugins/nowplaying.sh"
