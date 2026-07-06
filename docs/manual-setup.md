# Manual Setup

Use this after automated package, config, and defaults work is complete.

## Account Sign-In

Sign into:

- iCloud
- App Store
- Adobe Creative Cloud
- Affinity
- Autodesk Fusion
- Bitwarden
- Claude
- Codex
- Cursor
- Discord
- GitHub CLI
- Microsoft apps
- Proton Mail
- Raycast
- Steam
- Telegram
- Tailscale
- Visual Studio Code
- Zed
- Zoom
- Any other account-backed apps installed during setup

## Private Material To Restore

Restore these from a private source, not from this repo:

- SSH keys
- API keys and tokens
- App licenses
- rclone remotes
- Git signing config
- SMB/NAS password for the `~/smb` automount (Bitwarden; see `docs/smb-automount.md`)
- Codex, Claude, OpenCode, cmux, atuin, Raycast, Zed, and other private app state
- pi provider auth (re-login inside pi; see `docs/ai-agents.md`)

## Privacy And Security Permissions

Grant permissions in System Settings > Privacy & Security as prompted.

Accessibility:

- Hyperkey
- Maccy
- Raycast
- Rectangle
- Wispr Flow
- BetterDisplay
- Window, keyboard, and automation tools

Input Monitoring:

- Hyperkey
- Maccy
- Raycast
- Rectangle
- Wispr Flow
- Terminal and editor apps if prompted

Screen & System Audio Recording:

- OBS
- Zoom
- Teams
- Discord
- Wispr Flow
- Screenshot and screen-share tools

Microphone:

- OBS
- Zoom
- Teams
- Discord
- Wispr Flow
- Browsers
- Audio tools

Full Disk Access:

- Terminal
- Ghostty
- VS Code
- Zed
- Backup and sync tools
- Developer agents as needed

Automation:

- Raycast
- Terminal and editor apps
- Developer agents as prompted

## Login Items And Background Items

Review login items/background items for:

- BetterDisplay
- Caffeine
- Finicky
- Hyperkey
- Ice
- Maccy
- Raycast
- Rectangle
- Tailscale
- Wispr Flow
- Agent apps

## Device And Extension Checks

Verify after reboot:

- MOTU M Series driver and audio device
- iLok License Manager
- Adobe background services
- BetterDisplay
- Virtual display and audio tools

## Manual App Installs

These apps are present in `inventory/apps.md` but are not currently installed as Homebrew casks or Mac App Store apps on this Mac. Restore them manually, through their vendor installers, or through the owning app suite.

- Adobe Photoshop 2026 - Install through Adobe Creative Cloud after signing in
- Autodesk Fusion - Autodesk installer; current app bundles live in `~/Applications`
- [Busylight4MSTeams](https://www.plenom.com/downloads/download-software/) - Plenom software downloads
- Clips - Current source is not captured; verify whether it should be restored
- [FL Studio 2025](https://www.image-line.com/fl-studio/download) - Image-Line installer
- [FL Cloud Plugins](https://www.image-line.com/fl-cloud/whats-included#plugins) - Install/update through FL Cloud after signing into FL Studio
- Icon Composer - Apple developer app; restore from the current Apple distribution source
- Archetype Gojira X - Neural DSP installer and iLok activation
- [Ollama](https://ollama.com/download) - Ollama desktop app; afterwards restore the pi local-agent model per `docs/ai-agents.md`
- Openscreen - Current source is not captured; verify before restore

## Other Manual Follow-Ups

- Recreate the Shortcuts screenshot-rename automation (`docs/shortcuts-automations.md`); enable ChatGPT under System Settings > Apple Intelligence & Siri first.
- Enter the SMB password when setting up the automount (`docs/smb-automount.md`).
- Sign into Supacode so it reinstalls its `supacode-cli` skill and Codex hooks (`docs/ai-agents.md`).
