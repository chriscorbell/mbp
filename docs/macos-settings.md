# macOS Settings

Apply these settings after Homebrew packages and tracked config are installed. Some settings are not reliably scriptable and are listed as manual checks.

## Battery

Desired state:

- Charge limit: 80 percent
- Energy mode on battery: automatic
- Energy mode on power adapter: high power
- Turn display off on power adapter when inactive: never

Commands:

```sh
defaults write com.apple.batteryui.charging.mac com.apple.batteryui.charging.mac.prior.limit -int 80
sudo pmset -b powermode 0
sudo pmset -c powermode 2
sudo pmset -c displaysleep 0
```

## Accessibility And Trackpad

Desired state:

- Use trackpad for dragging: enabled
- Tap to click: enabled
- Natural scrolling: disabled

Commands:

```sh
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
```

## Menu Bar

Desired state:

- Clock shows seconds
- Spotlight hidden from menu bar
- Battery percentage visible

Commands:

```sh
defaults write com.apple.menuextra.clock ShowSeconds -bool true
defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true
defaults -currentHost write com.apple.controlcenter Battery -int 8
defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
defaults -currentHost write com.apple.controlcenter Spotlight -int 8
```

## Desktop And Dock

Desired state:

- Dock is empty and autohidden
- Dock autohide delay is removed
- Minimize animation uses scale
- Title bar double-click action fills the window
- Desktop icons hidden
- Desktop widgets hidden
- Wallpaper click only shows desktop in Stage Manager
- Window tiling by edge drag/menu bar/Option accelerator disabled

Commands:

```sh
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock mineffect -string scale
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

defaults write NSGlobalDomain AppleActionOnDoubleClick -string Fill
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
defaults write com.apple.WindowManager HideDesktop -bool true
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.WindowManager StageManagerHideWidgets -bool true
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
```

## Finder

Desired state:

- Show all file extensions
- Show path bar
- Show status bar

Commands:

```sh
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
```

## Keyboard

Desired state:

- Key repeat rate: fastest
- Delay until repeat: shortest
- Correct spelling automatically: disabled
- Capitalize words automatically: disabled
- Show inline predictive text: disabled
- Show suggested replies: disabled
- Add period with double-space: disabled
- Smart quotes and dashes: disabled

Commands:

```sh
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
defaults write NSGlobalDomain NSSmartReplyEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
```

## Screenshots

Desired state:

- Screenshots save to `~/Pictures/Screenshots` as files (the Shortcuts screenshot-rename automation watches this folder; see `docs/shortcuts-automations.md`)

Commands:

```sh
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "~/Pictures/Screenshots"
defaults write com.apple.screencapture target -string file
killall SystemUIServer >/dev/null 2>&1 || true
```

## Rectangle

Rectangle stores all preferences in `defaults`. Desired state:

- Recommended (alternate) default shortcuts, any-shortcut recording allowed
- 24 px gaps between windows, 38 px top screen-edge gap (no top gap on notch displays, gap skipped on the top edge)
- Repeated shortcut cycles through half sizes (`subsequentExecutionMode 1`)
- Restore original size on unsnap disabled (`unsnapRestore 2`), window snapping disabled (`windowSnapping 2`)
- Launch on login, menu bar icon visible
- Custom shortcuts: Almost Maximize = ⌥⌘Return, Reflow Todo = ⌃⌥N, Toggle Todo = ⌃⌥B

Commands (quit Rectangle first, reopen after):

```sh
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -int 1
defaults write com.knollsoft.Rectangle allowAnyShortcut -int 1
defaults write com.knollsoft.Rectangle gapSize -int 24
defaults write com.knollsoft.Rectangle screenEdgeGapTop -int 38
defaults write com.knollsoft.Rectangle screenEdgeGapTopNotch -float 0.001
defaults write com.knollsoft.Rectangle skipGapTopEdge -int 1
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1
defaults write com.knollsoft.Rectangle unsnapRestore -int 2
defaults write com.knollsoft.Rectangle windowSnapping -int 2
defaults write com.knollsoft.Rectangle launchOnLogin -int 1
defaults write com.knollsoft.Rectangle hideMenubarIcon -int 0
defaults write com.knollsoft.Rectangle almostMaximize -dict keyCode -int 36 modifierFlags -int 1572864
defaults write com.knollsoft.Rectangle reflowTodo -dict keyCode -int 45 modifierFlags -int 786432
defaults write com.knollsoft.Rectangle toggleTodo -dict keyCode -int 11 modifierFlags -int 786432
open -a Rectangle
```

## Maccy

Maccy stores all preferences in `defaults`. Desired state:

- Open popup: ⇧⌘C, at the cursor; delete and pin shortcuts cleared
- History: 512 items, sorted by last copied, 1.5 s preview delay
- Paste by default with formatting removed
- Title, search, and footer shown; menu bar icon hidden (sketchybar replaces the menu bar)
- Clipboard types: text, rich text, HTML, images, file URLs

Commands (quit Maccy first, reopen after):

```sh
defaults write org.p0deje.Maccy KeyboardShortcuts_popup -string '{"carbonKeyCode":8,"carbonModifiers":768}'
defaults write org.p0deje.Maccy KeyboardShortcuts_delete -int 0
defaults write org.p0deje.Maccy KeyboardShortcuts_pin -int 0
defaults write org.p0deje.Maccy historySize -int 512
defaults write org.p0deje.Maccy sortBy -string lastCopiedAt
defaults write org.p0deje.Maccy previewDelay -int 1500
defaults write org.p0deje.Maccy popupPosition -string cursor
defaults write org.p0deje.Maccy pasteByDefault -int 1
defaults write org.p0deje.Maccy removeFormattingByDefault -int 1
defaults write org.p0deje.Maccy showTitle -int 1
defaults write org.p0deje.Maccy showSearch -int 1
defaults write org.p0deje.Maccy showFooter -int 1
defaults write org.p0deje.Maccy showInStatusBar -int 0
defaults write org.p0deje.Maccy windowSize -string "[450,800]"
defaults write org.p0deje.Maccy enabledPasteboardTypes -array "public.utf8-plain-text" "public.rtf" "public.html" "public.tiff" "public.png" "public.file-url"
open -a Maccy
```

## Restart Affected Services

Run after applying defaults:

```sh
killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
killall ControlCenter >/dev/null 2>&1 || true
```

## Manual Checks

These are not reliably scriptable:

- Disable True Tone in System Settings > Displays.
- Confirm battery charging limit in System Settings > Battery if macOS changes the backing defaults key.
- Confirm trackpad dragging in System Settings > Accessibility > Pointer Control > Trackpad Options.
