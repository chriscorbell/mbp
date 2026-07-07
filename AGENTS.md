# Agent Instructions

Use this repo to set up a new or factory-reset macOS machine for Chris. Treat the repo as desired state and work through it incrementally.

## Operating Rules

- Start by inspecting the machine: `sw_vers`, `uname -m`, `xcode-select -p`, `command -v brew`, `git status --short`, and current user/home directory.
- Keep the user informed before major phases: Homebrew install, package installs, config overwrites, sudoers changes, and macOS defaults.
- Ask before enabling passwordless sudo. If approved, validate the sudoers fragment with `visudo -cf` before installing it.
- Back up any existing user config before replacing it. Use names like `.pre-mbp.backup` and do not overwrite an existing backup.
- Never commit or copy secrets into this repo.
- Prefer idempotent commands. Check whether an item is already installed before installing it.
- If a command fails because an app already exists outside Homebrew, verify the app bundle and continue.
- Do not recreate a monolithic setup script. The repo is intentionally agent-first.
- At the end, summarize what changed, what was skipped, and what still needs manual work.

## Desired State Files

- `inventory/homebrew-taps.md`: Homebrew taps to add before installing packages.
- `inventory/homebrew-formulae.md`: Homebrew leaves only (`brew leaves` output, some tap-qualified). Dependencies are not listed; `brew install` resolves them.
- `inventory/homebrew-casks.md`: current installed Homebrew cask snapshot from this Mac.
- `inventory/mas-apps.md`: Mac App Store apps. Install with `mas` only after the App Store is signed in.
- `inventory/apps.md`: tracked non-native app bundles to restore. This is not necessarily every app bundle physically present on the source Mac.
- `inventory/vscode-extensions.md`: VS Code extensions to install with the `code` CLI.
- `inventory/cli-tools.md`: global CLI tools installed outside Homebrew (npm -g, uv tools, go, rustup).
- `inventory/agent-skills.md`: agent skills to reinstall with skills.sh.
- `launchd/`: user LaunchAgents to restore (currently the Clips autostart; installed per `docs/manual-setup.md`).
- `.zshrc`, `.finicky.js`, `.config/`, `vscode/settings.json`: tracked user config (includes the full sketchybar config).
- `docs/macos-settings.md`: macOS defaults and manual settings, including Rectangle, Maccy, and screenshot location.
- `docs/dotfiles.md`: install rules for tracked config.
- `docs/ai-agents.md`: pi + Ollama local agent, Claude Code plugins, Codex settings.
- `docs/smb-automount.md`: autofs SMB automount under `~/smb` (needs the SMB password from the user).
- `docs/shortcuts-automations.md`: Shortcuts app automations to recreate manually.
- `docs/manual-setup.md`: account sign-ins, privacy permissions, and manual installers.

## Setup Phases

### 1. Preflight

Verify this is macOS and capture the current state:

```sh
sw_vers
uname -m
id -un
git status --short
xcode-select -p || true
command -v brew || true
```

If command line tools are missing, install them before Homebrew:

```sh
xcode-select --install
```

### 2. Homebrew

Install Homebrew if missing, then initialize it for the current shell.

```sh
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew update
```

Add taps from `inventory/homebrew-taps.md`, then install formulae and casks from the inventory files. Skip blank lines and comments. If Homebrew refuses a third-party tap as untrusted, run `brew trust <tap>` for taps in the inventory — they are already vetted.

Suggested pattern:

```sh
while IFS= read -r tap; do
  [ -z "$tap" ] || [ "${tap#\#}" != "$tap" ] && continue
  brew tap "$tap"
done < inventory/homebrew-taps.md
```

For formulae, check `brew list --formula "$name"` before `brew install "$name"`.

For casks, check `brew list --cask "$name"` before `brew install --cask "$name"`. If Homebrew refuses because the app bundle already exists, verify the app in `/Applications` and continue.

Known current cask app bundle names that may differ from cask names:

- `cmux`: `/Applications/cmux.app`
- `bambu-studio`: `/Applications/BambuStudio.app`
- `ente-auth`: `/Applications/Ente Auth.app`
- `flux-markdown`: `/Applications/FluxMarkdown.app`
- `helium-browser`: `/Applications/Helium.app`
- `ilok-license-manager`: `/Applications/iLok License Manager.app`
- `localsend`: `/Applications/LocalSend.app`
- `motu-m-series`: `/Applications/MOTU M Series System Extension.app`
- `opencode-desktop`: `/Applications/OpenCode.app`
- `orbstack`: `/Applications/OrbStack.app`
- `proton-mail`: `/Applications/Proton Mail.app`
- `raspberry-pi-imager`: `/Applications/Raspberry Pi Imager.app`
- `tailscale-app`: `/Applications/Tailscale.app`
- `visual-studio-code`: `/Applications/Visual Studio Code.app`
- `windows-app`: `/Applications/Windows App.app`
- `wispr-flow`: `/Applications/Wispr Flow.app`
- `zoom`: `/Applications/zoom.us.app`

### 3. Mac App Store

Use `mas` from the formula inventory. First check whether the user is signed in:

```sh
mas account
```

If signed in, install the apps listed in `inventory/mas-apps.md`. If not signed in, skip and record the manual follow-up.

### 4. VS Code

Install VS Code settings and extensions using `docs/dotfiles.md` and `inventory/vscode-extensions.md`.

The `code` CLI may be available at either:

- `code`
- `/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code`

### 5. Dotfiles

Follow `docs/dotfiles.md`. Preserve existing user files before replacing `.zshrc` or VS Code settings.

### 6. macOS Settings

Apply scriptable defaults from `docs/macos-settings.md`. Some settings still require System Settings and are intentionally listed as manual checks.

Restart affected services after defaults changes:

```sh
killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
killall ControlCenter >/dev/null 2>&1 || true
```

### 7. Agents, Services, And Automations

- Install global CLI tools from `inventory/cli-tools.md`.
- Install agent skills from `inventory/agent-skills.md` with skills.sh.
- Set up Claude Code plugins and Codex settings from `docs/ai-agents.md`. The pi + Ollama agent restores from its own repo (linked there) after Ollama is installed.
- Start sketchybar per the Sketchybar section of `docs/dotfiles.md`.
- Set up the SMB automount from `docs/smb-automount.md`. This needs sudo and the SMB password from the user; never write the real password into this repo.
- Walk the user through recreating Shortcuts automations from `docs/shortcuts-automations.md` (not scriptable).

### 8. Manual Setup

Use `docs/manual-setup.md` as the final checklist. Verify non-native apps against `inventory/apps.md`. Do not try to bypass account sign-ins, privacy prompts, or license activation.

## Audit Mode

When asked to "audit this Mac against the repo", produce a drift report and change nothing. Compare each desired-state file against the live machine, in both directions:

- Taps: `brew tap` vs `inventory/homebrew-taps.md`.
- Formulae: `brew leaves` vs `inventory/homebrew-formulae.md`.
- Casks: `brew list --cask` vs `inventory/homebrew-casks.md`.
- MAS apps: `mas list` vs `inventory/mas-apps.md`.
- Tracked app bundles: entries in `inventory/apps.md` vs what exists on disk.
- VS Code extensions: `code --list-extensions` vs `inventory/vscode-extensions.md`.
- Global CLI tools: `npm ls -g --depth=0`, `uv tool list`, `ls ~/go/bin`, and `command -v rustup` vs `inventory/cli-tools.md`.
- Agent skills: skill names in `~/.agents/.skill-lock.json` vs `inventory/agent-skills.md`.
- pi agent: `diff -r ~/.pi/agent` (excluding `auth.json`, `sessions/`, `node_modules/`) against the `agent/` directory of the `pi-coding-agent-config` checkout (`~/pi-coding-agent-config`), plus `~/.pi/web-search.json` and the installed `local.ollama-env.plist` vs that repo. Report drift there as "update the pi repo", not this one.
- Claude Code plugins: `claude plugin list` (or `~/.claude/plugins/installed_plugins.json`) vs `docs/ai-agents.md`.
- Dotfiles: `diff` each tracked file (`.zshrc`, `.finicky.js`, `vscode/settings.json`, every file under `.config/`) against its live counterpart.
- macOS defaults: `defaults read` each key documented in `docs/macos-settings.md` (including the Rectangle domain) vs the documented value.
- SMB automount: `/etc/auto_master` line and the hosts/shares in `/etc/auto_smb` (needs sudo; ignore the password line) vs `docs/smb-automount.md`.
- Shortcuts: `shortcuts list` contains `Rename Screenshot from Image Content`. That command can return empty output in a non-interactive shell; fall back to `sqlite3 ~/Library/Shortcuts/Shortcuts.sqlite "select ZNAME from ZSHORTCUT where ZTOMBSTONED=0;"` before reporting the shortcut missing.

Report in three groups: **on the Mac but not in the repo**, **in the repo but not on the Mac**, and **tracked but different** (show the diff or both values). Do not fix anything; the user decides per item which side is correct and then updates the repo or the machine.

## Optional Passwordless Sudo

Only do this after explicit user approval.

```sh
username="$(id -un)"
sudoers_dir="/etc/sudoers.d"
sudoers_file="$sudoers_dir/mbp-$username"
sudoers_line="$username ALL=(ALL) NOPASSWD: ALL"
tmp="$(mktemp)"
printf '%s\n' "$sudoers_line" > "$tmp"
visudo -cf "$tmp"
sudo install -d -m 0755 "$sudoers_dir"
sudo install -m 0440 "$tmp" "$sudoers_file"
rm -f "$tmp"
```

## Completion Report

End with:

- Homebrew formulae installed, skipped, or failed.
- Homebrew casks installed, skipped, or failed.
- MAS apps installed or skipped.
- Tracked app bundles from `inventory/apps.md` present, installed, or still manual.
- Config files copied and backups created.
- macOS defaults applied.
- Manual account, privacy, extension, and installer work remaining.
