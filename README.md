# mbp

this is a setup script for macOS that does the following:

- enables passwordless sudo
- installs homebrew
- uses homebrew and mas to install my cli packages and gui apps
- implements my dotfiles
- configures the macOS settings listed below where scriptable

### installation

clone or download the repo, navigate into the repo directory with terminal and run `./mbp.sh`

sign into the Mac App Store before running the script so `mas` can install App Store apps.

### restore notes

the script handles packages, casks, tracked dotfiles, VS Code settings, VS Code extensions, and scriptable macOS defaults. the following still need manual attention after a fresh install:

- disable true tone in system settings -> displays
- sign into iCloud, App Store, Adobe Creative Cloud, Bitwarden, ChatGPT, Claude, Codex, GitHub CLI, Microsoft apps, Proton Mail, Steam, Telegram, Tailscale, Zoom, and any other account-backed apps
- restore SSH keys and any private config that is intentionally not tracked here
- review login items/background items for apps like BetterDisplay, Caffeine, DockDoor, Finicky, Hyperkey, Ice, Maccy, Raycast, Rectangle, Stats, Tailscale, Wispr Flow, and any agent apps
- grant privacy permissions in system settings -> privacy & security:
  - accessibility: Hyperkey, Maccy, Raycast, Rectangle, Wispr Flow, DockDoor, BetterDisplay, Stats, and any window/keyboard automation tools
  - input monitoring: Hyperkey, Maccy, Raycast, Rectangle, Wispr Flow, and terminal/editor apps if prompted
  - screen & system audio recording: OBS, Zoom, Teams, Discord, Wispr Flow, and screenshot/screen-share tools
  - microphone: OBS, Zoom, Teams, Discord, Wispr Flow, browsers, and audio tools
  - full disk access: terminal, Ghostty, VS Code, Zed, backup/sync tools, and developer agents as needed
  - automation: Raycast, terminal/editor apps, and developer agents as prompted
- restore or re-export app-specific config for Raycast, Zed, rclone, atuin, opencode, cmux, Codex, Claude, and git; do not commit secrets directly to this repo
- verify audio/device extensions for MOTU M Series, iLok License Manager, Adobe apps, BetterDisplay, and virtual display/audio tools after reboot

### manual app installs

these apps are present on this Mac but are not installed by the script because no reliable Homebrew cask or Mac App Store source was found:

- [Busylight4MSTeams](https://www.plenom.com/downloads/download-software/) - Plenom software downloads
- [FL Studio 2025](https://www.image-line.com/fl-studio/download) - Image-Line installer
- [FL Cloud Plugins](https://www.image-line.com/fl-cloud/whats-included#plugins) - install/update through FL Cloud after signing into FL Studio
- [PTSBuilder](https://github.com/chriscorbell/PTSBuilder) - local/custom app source
- [QLCodec-mkv](https://github.com/Oil3/Mkv-Quicklook) - Quick Look MKV plugin
- [Reolink](https://reolink.com/software-and-manual/) - Reolink client download
- [WinDiskWriter](https://github.com/TechUnRestricted/windiskwriter) - Windows USB writer for macOS

# macOS settings

### battery

charge limit = 80%
energy mode on battery = auto
energy mode on power adapter = high

### accessibility

pointer control -> trackpad options:

- use trackpad for dragging = enabled

### menu bar

clock: show time with seconds = enabled
remove spotlight
battery: show percentage = enabled

### desktop & dock

remove all items from dock
set dock to autohide
minimize window animation = scale
title bar double-click action = fill
show items = uncheck both on desktop and in stage manager
click wallpaper to show desktop = only in stage manager
show widgets = uncheck both on desktop and in stage manager
drag windows to left or right edge of screen to tile = disabled
drag windows to menu bar to fill screen = disabled
hold option key while dragging windows to tile = disabled
dock autohide = true
dock autohide-delay = 0.0
dock autohide-time-modifier = 0.5

### finder

show all extensions = true
show path = true
show status bar = true

### display

true tone = disabled

### lock screen

turn display off on power adapter when inactive = never

### keyboard

key repeat rate = fastest
delay until repeat = shortest
input sources = us -> edit:

- correct spelling automatically = disabled
- capitalize words automatically = disabled
- show inline predictive text = disabled
- show suggested replies = disabled
- add period with double-space = disabled
- use smart quotes and dashes = disabled

### trackpad

tap to click = enabled
natural scrolling = disabled
