#!/bin/bash
# Codex + Claude + Copilot usage (% remaining) via codexbar, with detail popups.
# ponytail: one `--provider codex,claude,copilot` call updates all three items,
# so this script is attached to `codex` only and drives the others too.
# Providers differ in shape: codex/claude have a 5h + weekly window; copilot has
# a single monthly window. Labels/popup lines adapt from windowMinutes + resets.
source "$HOME/.config/sketchybar/colors.sh"

# --- Hover tooltip: show popup shortly after mouse enters, hide on exit (no network).
#     Shared by all three items; the sleep is cancelled if the mouse leaves first.
MARK="/tmp/sketchybar_hover_${NAME}"
case "$SENDER" in
  mouse.entered)
    touch "$MARK"
    ( sleep 0.25; [ -f "$MARK" ] && sketchybar --set "$NAME" popup.drawing=on ) >/dev/null 2>&1 &
    disown 2>/dev/null
    exit 0 ;;
  mouse.exited)
    rm -f "$MARK"
    sketchybar --set "$NAME" popup.drawing=off
    exit 0 ;;
esac

# --- Data refresh. Only codex actually fetches; it populates all three items,
#     so claude/copilot updates are no-ops (they exist only for hover handling).
[ "$NAME" = "codex" ] || exit 0

CB="$(command -v codexbar || echo /opt/homebrew/bin/codexbar)"

color_for() { # $1 = percent remaining -> green plenty, red almost gone
  if   [ "$1" -le 20 ]; then echo "$RED"
  elif [ "$1" -le 50 ]; then echo "$PEACH"
  else echo "$GREEN"; fi
}

win_label() { # $1 = windowMinutes -> short human name
  case "$1" in
    300)   echo "5h"    ;;
    1440)  echo "Day"   ;;
    10080) echo "Week"  ;;
    null|"") echo "Month" ;;   # copilot: no windowMinutes, quota is monthly
    *)     echo "Limit" ;;
  esac
}

reset_desc() { # $1 = resetDescription  $2 = resetsAt ISO -> printable reset
  if [ -n "$1" ] && [ "$1" != "null" ]; then printf '%s' "$1"; return; fi
  if [ -n "$2" ] && [ "$2" != "null" ]; then
    date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$2" "+%b %-d" 2>/dev/null && return
  fi
  printf '—'
}

J="$("$CB" usage --provider codex,claude,copilot --json 2>/dev/null)"

set_win() { # $1 item.child  $2 row-json  $3 primary|secondary
  local child="$1" row="$2" w="$3" used rem wm desc at lbl
  used=$(echo "$row" | jq -r ".usage.$w.usedPercent   // 0    | round")
  wm=$(  echo "$row" | jq -r ".usage.$w.windowMinutes  // \"null\"")
  desc=$(echo "$row" | jq -r ".usage.$w.resetDescription // \"null\"")
  at=$(  echo "$row" | jq -r ".usage.$w.resetsAt         // \"null\"")
  # A window is present only if it advertises a reset; else hide its popup line.
  if [ "$desc" = "null" ] && [ "$at" = "null" ]; then
    sketchybar --set "$child" drawing=off 2>/dev/null
    return 1
  fi
  rem=$(( 100 - used ))
  lbl=$(win_label "$wm")
  sketchybar --set "$child" drawing=on \
    label="$(printf '%-5s %s%% left  · resets %s' "$lbl:" "$rem" "$(reset_desc "$desc" "$at")")" 2>/dev/null
  echo "$rem"
}

set_one() { # $1 = provider/item name (codex|claude|copilot)
  local prov="$1" row rem
  row="$(echo "$J" | jq -c --arg pr "$prov" '.[] | select(.provider==$pr)')"
  if [ -z "$row" ]; then
    sketchybar --set "$prov" label="—" label.color="$SUBTEXT"
    return
  fi
  rem=$(set_win "$prov.p" "$row" primary)   # primary drives the pill label
  set_win "$prov.s" "$row" secondary >/dev/null
  [ -n "$rem" ] && sketchybar --set "$prov" label="${rem}%" label.color="$(color_for "$rem")"
}

set_one codex
set_one claude
set_one copilot
