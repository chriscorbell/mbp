#!/bin/bash
# Temp + condition from wttr.in (IP-based location). Icon reflects condition and
# popup rows show current detail.
source "$HOME/.config/sketchybar/colors.sh"

MARK="/tmp/sketchybar_hover_${NAME:-weather}"
case "$SENDER" in
  mouse.entered)
    touch "$MARK"
    ( sleep 0.25; [ -f "$MARK" ] && sketchybar --set "${NAME:-weather}" popup.drawing=on ) >/dev/null 2>&1 &
    disown 2>/dev/null
    exit 0 ;;
  mouse.exited)
    rm -f "$MARK"
    sketchybar --set "${NAME:-weather}" popup.drawing=off
    exit 0 ;;
esac

DATA=$(curl -s --max-time 5 "wttr.in/?format=j1" 2>/dev/null)
[ -z "$DATA" ] && exit 0          # keep last value on failure

TEMP="$(echo "$DATA" | jq -r '.current_condition[0].temp_F // empty')"
FEELS="$(echo "$DATA" | jq -r '.current_condition[0].FeelsLikeF // empty')"
COND="$(echo "$DATA" | jq -r '.current_condition[0].weatherDesc[0].value // empty')"
HUMIDITY="$(echo "$DATA" | jq -r '.current_condition[0].humidity // empty')"
WIND_SPEED="$(echo "$DATA" | jq -r '.current_condition[0].windspeedMiles // empty')"
WIND_DIR="$(echo "$DATA" | jq -r '.current_condition[0].winddir16Point // empty')"
PRECIP="$(echo "$DATA" | jq -r '.current_condition[0].precipInches // empty')"
PRESSURE="$(echo "$DATA" | jq -r '.current_condition[0].pressure // empty')"
UV="$(echo "$DATA" | jq -r '.current_condition[0].uvIndex // empty')"
VISIBILITY="$(echo "$DATA" | jq -r '.current_condition[0].visibilityMiles // empty')"
CITY="$(echo "$DATA" | jq -r '.nearest_area[0].areaName[0].value // empty')"
REGION="$(echo "$DATA" | jq -r '.nearest_area[0].region[0].value // empty')"

if [ -z "$TEMP" ] || [ -z "$COND" ]; then
  exit 0
fi

TEMP="${TEMP}°F"
FEELS="${FEELS}°F"
HUMIDITY="${HUMIDITY}%"
WIND="${WIND_DIR} ${WIND_SPEED} mph"
PRECIP="${PRECIP} in"
PRESSURE="${PRESSURE} hPa"
VISIBILITY="${VISIBILITY} mi"

case "$COND" in
  *[Tt]hunder*)                        ICON="󰖓" ;;
  *[Ss]now*|*[Ss]leet*|*[Bb]lizzard*)  ICON="󰖘" ;;
  *[Rr]ain*|*[Dd]rizzle*|*[Ss]hower*)  ICON="󰖗" ;;
  *[Ff]og*|*[Mm]ist*|*[Hh]aze*)        ICON="󰖑" ;;
  *[Pp]artly*)                         ICON="󰖕" ;;
  *[Cc]loud*|*[Oo]vercast*)            ICON="󰖐" ;;
  *[Cc]lear*|*[Ss]unny*)               ICON="󰖙" ;;
  *)                                   ICON="󰖙" ;;
esac

sketchybar --set "$NAME" icon="$ICON" icon.color="$YELLOW" label="$TEMP"

sketchybar --set weather.location  label="${CITY}, ${REGION}" \
           --set weather.condition label="$COND" \
           --set weather.feels     label="Feels $FEELS  Humidity $HUMIDITY" \
           --set weather.wind      label="Wind $WIND  Rain $PRECIP" \
           --set weather.extra     label="UV $UV  Visibility $VISIBILITY  Pressure $PRESSURE"
