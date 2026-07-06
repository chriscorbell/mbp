#!/bin/bash
# Smooth marquee daemon for the nowplaying item. Runs as a single background
# loop (sketchybar's update_freq floor is 1s, too coarse for smooth scrolling),
# sliding a WIDTH-char window over the full title one char per frame with a
# pause at each end. nowplaying.sh only refreshes the full title into np_full.

WIDTH=28        # visible characters
INTERVAL=0.2    # seconds per frame
HOLD=15         # frames to pause at each end (~3s at 0.2s/frame)
full_file="$HOME/.cache/sketchybar/np_full"

lastfull="__init__"; lastvis="__init__"
pos=0; dir=1; hold=$HOLD

while :; do
  full="$(cat "$full_file" 2>/dev/null)"

  if [ "$full" != "$lastfull" ]; then          # new track: reset scroll
    lastfull="$full"; lastvis="__init__"
    pos=0; dir=1; hold=$HOLD
    [ -z "$full" ] && sketchybar --set nowplaying drawing=off
  fi

  if [ -z "$full" ]; then sleep 1; continue; fi

  len=${#full}
  if [ "$len" -le "$WIDTH" ]; then
    vis="$full"
  else
    maxpos=$((len - WIDTH))
    vis="${full:pos:WIDTH}"
    if [ "$hold" -gt 0 ]; then
      hold=$((hold - 1))
    else
      pos=$((pos + dir))
      (( pos >= maxpos )) && { pos=$maxpos; dir=-1; hold=$HOLD; }
      (( pos <= 0 ))      && { pos=0;      dir=1;  hold=$HOLD; }
    fi
  fi

  [ "$vis" != "$lastvis" ] && { sketchybar --set nowplaying drawing=on label="$vis"; lastvis="$vis"; }
  sleep "$INTERVAL"
done
