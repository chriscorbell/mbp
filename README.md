# mbp

Agent-first setup notes for Chris's MacBook Pro.

This repo is the desired state for a new or factory-reset Mac. It is intentionally not a bootstrap script. The primary workflow is to point Codex at this repo and ask it to set up the machine from the repo contents.

## Use

1. Clone this repo on the Mac.
2. Open Codex in the repo root.
3. Ask: `Set up this Mac using this repo. Follow AGENTS.md.`
4. Keep the session open while Codex works through the phases, verifies each one, and reports any manual steps that need your account credentials or privacy approvals.

The agent entry point is [AGENTS.md](AGENTS.md).

## Source Of Truth

- Homebrew taps: [inventory/homebrew-taps.md](inventory/homebrew-taps.md)
- Homebrew formulae: [inventory/homebrew-formulae.md](inventory/homebrew-formulae.md)
- Homebrew casks: [inventory/homebrew-casks.md](inventory/homebrew-casks.md)
- Mac App Store apps: [inventory/mas-apps.md](inventory/mas-apps.md)
- Tracked app bundles: [inventory/apps.md](inventory/apps.md)
- VS Code extensions: [inventory/vscode-extensions.md](inventory/vscode-extensions.md)
- Global CLI tools: [inventory/cli-tools.md](inventory/cli-tools.md)
- Agent skills: [inventory/agent-skills.md](inventory/agent-skills.md)
- Dotfiles and app config: [.zshrc](.zshrc), [.finicky.js](.finicky.js), [.config](.config), [vscode/settings.json](vscode/settings.json)
- macOS settings (including Rectangle and screenshots): [docs/macos-settings.md](docs/macos-settings.md)
- AI agents and plugins (pi + Ollama, Claude Code, Codex): [docs/ai-agents.md](docs/ai-agents.md)
- SMB automount under `~/smb`: [docs/smb-automount.md](docs/smb-automount.md)
- Shortcuts automations: [docs/shortcuts-automations.md](docs/shortcuts-automations.md)
- Manual installs and restore checks: [docs/manual-setup.md](docs/manual-setup.md)
- Dotfile install rules: [docs/dotfiles.md](docs/dotfiles.md)

## What The Agent Should Do

Codex should use the plain inventories and docs to perform an idempotent setup. It should inspect the current machine first, install missing packages, copy tracked config with backups, apply scriptable macOS defaults, verify app bundles against the tracked restore set, and leave a clear list of manual follow-up items.

Sensitive work is deliberately left as agent-mediated work rather than hidden inside a script. Codex should ask before changing sudoers, overwriting existing config, or making choices that require credentials.

## What Is Not Tracked

Do not add secrets or private machine state to this repo. That includes SSH keys, API keys, app tokens, Bitwarden data, iCloud data, license files, private rclone remotes, private Codex/Claude/GitHub auth material, and app-specific cloud sync state.

## Maintenance

To check for drift, ask an agent: `Audit this Mac against this repo. Follow the Audit Mode section of AGENTS.md.` It reports differences without changing anything.

When this Mac changes, update the relevant inventory or doc directly. Prefer small, reviewable changes:

- Add or remove Homebrew packages in `inventory/homebrew-*.md`.
- Refresh the tracked app bundle restore set in `inventory/apps.md`.
- Add or remove VS Code extensions in `inventory/vscode-extensions.md`.
- Update manual installers in `docs/manual-setup.md`.
- Update macOS preferences in `docs/macos-settings.md`.
- Commit only stable desired state, not temporary local experiments.
