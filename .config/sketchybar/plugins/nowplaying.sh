#!/bin/bash
# Refreshes the current track into np_full. The nowplaying-scroll.sh daemon
# reads that file and handles the scrolling/label. Falls back to Spotify/Music
# AppleScript, then the Zen window title, if MediaRemote has no playing item.

track=""
helper_source="$HOME/.config/sketchybar/helpers/nowplaying.swift"

if [ -r "$helper_source" ]; then
  track="$(swift "$helper_source" 2>/dev/null)"
fi

if [ -z "$track" ]; then
  for app in Spotify Music; do
    [ "$(osascript -e "application \"$app\" is running" 2>/dev/null)" != "true" ] && continue
    if [ "$(osascript -e "tell application \"$app\" to player state" 2>/dev/null)" = "playing" ]; then
      track=$(osascript -e "tell application \"$app\" to (get artist of current track) & \"  –  \" & (get name of current track)" 2>/dev/null)
      break
    fi
  done
fi

if [ -z "$track" ] && [ "$(osascript -e 'application "Zen" is running' 2>/dev/null)" = "true" ]; then
  track="$(osascript -e 'tell application "System Events" to tell process "zen" to get value of attribute "AXTitle" of window 1' 2>/dev/null)"
  track="${track% — Personal}"
  track="${track% - YouTube}"
fi

mkdir -p "$HOME/.cache/sketchybar"
printf '%s' "$track" > "$HOME/.cache/sketchybar/np_full"
