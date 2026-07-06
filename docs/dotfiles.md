# Dotfiles And App Config

Tracked config lives in:

- `.zshrc`
- `.config/`
- `vscode/settings.json`

## Install Rules

- Back up existing files before replacing them.
- Do not overwrite an existing backup.
- Do not copy secrets into this repo.
- Prefer merge-style config sync for `.config/`; do not delete unrelated user config unless the user explicitly asks.

## `.config`

Copy the tracked `.config` entries into `~/.config`.

```sh
mkdir -p "$HOME/.config"
rsync -a --exclude '.DS_Store' .config/ "$HOME/.config/"
```

Tracked entries:

- `btop/btop.conf`
- `gh/config.yml`
- `gh/hosts.yml`
- `ghostty/config`
- `nano/nanorc`
- `sketchybar/` (full config: `sketchybarrc`, `colors.sh`, `helpers/`, `plugins/`)
- `starship.toml`

## Sketchybar

After copying `.config/sketchybar`, make sure the scripts are executable and start the brew service (the `sketchybar` formula, `font-jetbrains-mono-nerd-font` cask, and plugin dependencies `jq` and `codexbar` are in the Homebrew inventories):

```sh
chmod +x "$HOME/.config/sketchybar/sketchybarrc" "$HOME/.config/sketchybar/colors.sh" "$HOME/.config/sketchybar/helpers/"*.sh "$HOME/.config/sketchybar/plugins/"*.sh
brew services start sketchybar
```

The bar replaces the stock menu bar top gap (Rectangle's 38 px `screenEdgeGapTop` in `docs/macos-settings.md` accounts for it). The `tailscale` plugin expects the Tailscale app CLI; `codexbar.sh` expects `codexbar` on PATH.

## `.zshrc`

Install the tracked `.zshrc` after backing up an existing file.

```sh
target="$HOME/.zshrc"
backup="$HOME/.zshrc.pre-mbp.backup"

if [ -f "$target" ] && ! cmp -s .zshrc "$target"; then
  [ -f "$backup" ] || cp "$target" "$backup"
fi

cp .zshrc "$target"
```

Open a new shell after installing:

```sh
exec zsh
```

## Hush Login

Create `~/.hushlogin` if it does not already exist.

```sh
touch "$HOME/.hushlogin"
```

## VS Code Settings

Install `vscode/settings.json` into VS Code's user settings path after backing up an existing settings file.

```sh
target_dir="$HOME/Library/Application Support/Code/User"
target="$target_dir/settings.json"
backup="$target_dir/settings.json.pre-mbp.backup"

mkdir -p "$target_dir"
if [ -f "$target" ] && ! cmp -s vscode/settings.json "$target"; then
  [ -f "$backup" ] || cp "$target" "$backup"
fi

cp vscode/settings.json "$target"
```

## VS Code Extensions

Use `inventory/vscode-extensions.md`.

```sh
code_cmd="$(command -v code || true)"
if [ -z "$code_cmd" ] && [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
  code_cmd="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [ -n "$code_cmd" ]; then
  while IFS= read -r extension; do
    [ -z "$extension" ] || [ "${extension#\#}" != "$extension" ] && continue
    "$code_cmd" --install-extension "$extension"
  done < inventory/vscode-extensions.md
fi
```
