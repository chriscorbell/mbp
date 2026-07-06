#!/bin/bash
# Show the focused app name with a matching (Material Design) Nerd Font glyph.

[ "$SENDER" != "front_app_switched" ] && exit 0

case "$INFO" in
  Safari*)                                          ICON="󰀹" ;;
  Google\ Chrome*)                                  ICON="󰊯" ;;
  Firefox*|Zen*|Arc)                                ICON="󰈹" ;;
  Code|Cursor|*Visual\ Studio*)                     ICON="󰨞" ;;
  Terminal|iTerm2|kitty|Alacritty|Ghostty|WezTerm) ICON="󰆍" ;;
  Finder)                                           ICON="󰉋" ;;
  Slack)                                            ICON="󰒱" ;;
  Discord)                                          ICON="󰙯" ;;
  Spotify)                                          ICON="󰓇" ;;
  Music)                                            ICON="󰎆" ;;
  Mail)                                             ICON="󰇮" ;;
  Messages)                                         ICON="󰍡" ;;
  Notes|Notion|Obsidian)                            ICON="󰠮" ;;
  Calendar)                                         ICON="󰃭" ;;
  System\ Settings)                                 ICON="󰒓" ;;
  zoom.us)                                          ICON="󰍹" ;;
  Preview)                                          ICON="󰋩" ;;
  *)                                                ICON="󰣆" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="$INFO"
