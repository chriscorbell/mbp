#!/bin/bash
# Tailscale state in the bar (green=running, red=stopped) + popup with details.
source "$HOME/.config/sketchybar/colors.sh"

TS="$(command -v tailscale || echo /usr/local/bin/tailscale)"
[ -x "$TS" ] || TS="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

J="$("$TS" status --json 2>/dev/null)"
if [ -z "$J" ]; then
  sketchybar --set "${NAME:-tailscale}" icon="󰦝" icon.color="$SUBTEXT"
  sketchybar --set tailscale.ip label="Tailscale unavailable" 2>/dev/null
  exit 0
fi

STATE="$(echo "$J" | jq -r '.BackendState // "Unknown"')"
IP="$(echo "$J" | jq -r '.Self.TailscaleIPs[0] // "—"')"
EXIT="$(echo "$J" | jq -r 'first((.Peer // {})[] | select(.ExitNode==true) | .HostName) // "none"')"
ONLINE="$(echo "$J" | jq -r '[(.Peer // {})[] | select(.Online==true)] | length')"
TOTAL="$(echo "$J" | jq -r '(.Peer // {}) | length')"

if [ "$STATE" = "Running" ]; then
  sketchybar --set "${NAME:-tailscale}" icon="󰦝" icon.color="$GREEN"
else
  sketchybar --set "${NAME:-tailscale}" icon="󰦝" icon.color="$RED"
fi

sketchybar --set tailscale.ip    label="IP:    $IP"                 2>/dev/null
sketchybar --set tailscale.exit  label="Exit:  $EXIT"               2>/dev/null
sketchybar --set tailscale.peers label="Peers: $ONLINE/$TOTAL online" 2>/dev/null
