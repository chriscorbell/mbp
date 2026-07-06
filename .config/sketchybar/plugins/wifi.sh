#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

# CoreWLAN gives the Wi-Fi device name + current RSSI (dBm) — no sudo/Location.
read -r wifi_dev rssi < <(swift "$HOME/.config/sketchybar/helpers/wifi-rssi.swift" 2>/dev/null)
wifi_dev="${wifi_dev:-en0}"
[[ "$rssi" =~ ^-?[0-9]+$ ]] || rssi=0

# Primary connection = interface of the default route (empty when offline).
iface="$(route get default 2>/dev/null | awk '/interface:/{print $2}')"
# ponytail: a full-tunnel VPN (e.g. Tailscale exit node) owns the default route;
# fall back to the physical Wi-Fi link state so we still report Wi-Fi vs Ethernet.
case "$iface" in
  utun*|ipsec*|ppp*)
    if ifconfig "$wifi_dev" 2>/dev/null | grep -q 'status: active'; then
      iface="$wifi_dev"; else iface="wired"; fi ;;
esac

if [ -z "$iface" ]; then
  sketchybar --set "$NAME" icon="󰤭" icon.color="$SUBTEXT" label="off"
elif [ "$iface" = "$wifi_dev" ]; then
  # Wi-Fi: strength ramp from RSSI (dBm), -55↑ full … below -80 none.
  if   [ "$rssi" -ge -55 ]; then icon="󰤨"
  elif [ "$rssi" -ge -65 ]; then icon="󰤥"
  elif [ "$rssi" -ge -72 ]; then icon="󰤢"
  elif [ "$rssi" -ge -80 ]; then icon="󰤟"
  else                           icon="󰤯"; fi
  sketchybar --set "$NAME" icon="$icon" icon.color="$SKY" label="Wi-Fi"
else
  sketchybar --set "$NAME" icon="󰈀" icon.color="$SKY" label="Ethernet"
fi
