#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

formulae=(
	adb-enhanced
	anomalyco/tap/opencode
	atuin
	bat
	bitwarden-cli
	btop
	cmatrix
	dart-sass
	deno
	direnv
	dust
	eza
	fastfetch
	fd
	ffmpeg-full
	fzf
	gh
	git
	go
	gstreamer
	hugo
	iperf3
	iproute2mac
	jq
	just
	lazydocker
	lazygit
	llmfit
	mactop
	make
	nano
	nanorc
	node
	nmap
	npm
	oven-sh/bun/bun
	pandoc
	philocalyst/tap/caligula
	pnpm
	potrace
	python
	rclone
	ripgrep
	starship
	tree
	uv
	volta
	watchexec
	wimlib
	woff2
	yarn
	yq
	yt-dlp
	zsh-autosuggestions
	zsh-syntax-highlighting
)

casks=(
	adobe-creative-cloud
	affinity
	android-platform-tools
	bambu-studio
	betterdisplay
	bitwarden
	caffeine
	chatgpt
	claude
	claude-code@latest
	codex
	codex-app
	codexbar
	discord
	dockdoor
	ente-auth
	finicky
	xykong/tap/flux-markdown
	font-inter
	font-jetbrains-mono-nerd-font
	font-sf-mono-nerd-font-ligaturized
	ghostty
	google-chrome
	helium-browser
	hyperkey
	ilok-license-manager
	jordanbaird-ice
	localsend
	maccy
	microsoft-edge
	microsoft-excel
	microsoft-outlook
	microsoft-powerpoint
	microsoft-teams
	microsoft-word
	moonlight
	motu-m-series
	mp3tag
	obs
	opencode-desktop
	orbstack
	pika
	proton-mail
	raspberry-pi-imager
	raycast
	rectangle
	stats
	steam
	stremio
	supacode
	t3-code
	tailscale-app
	telegram
	utm
	windows-app
	visual-studio-code
	vlc
	wispr-flow
	zed
	zen
	zoom
)

vscode_extensions=(
	anthropic.claude-code
	dbaeumer.vscode-eslint
	ecmel.vscode-html-css
	esbenp.prettier-vscode
	github.copilot-chat
	github.vscode-github-actions
	golang.go
	ms-vscode-remote.remote-ssh
	ms-vscode-remote.remote-ssh-edit
	ms-vscode.live-server
	ms-vscode.remote-explorer
	openai.chatgpt
	redhat.vscode-yaml
	shd101wyy.markdown-preview-enhanced
)

log() {
	printf '\n==> %s\n' "$1"
}

configure_passwordless_sudo() {
	local username sudoers_dir sudoers_file temp_file sudoers_line cleanup_command

	username="$(id -un)"
	sudoers_dir="/etc/sudoers.d"
	sudoers_file="$sudoers_dir/mbp-$username"
	sudoers_line="$username ALL=(ALL) NOPASSWD: ALL"
	temp_file="$(mktemp)"

	printf -v cleanup_command 'rm -f -- %q; trap - RETURN' "$temp_file"
	trap "$cleanup_command" RETURN

	if sudo test -f "$sudoers_file" && sudo grep -Fxq "$sudoers_line" "$sudoers_file"; then
		log "Passwordless sudo already configured for $username"
		return
	fi

	log "Configuring passwordless sudo for $username"
	sudo -v
	sudo install -d -m 0755 "$sudoers_dir"
	printf '%s\n' "$sudoers_line" > "$temp_file"
	visudo -cf "$temp_file"
	sudo install -m 0440 "$temp_file" "$sudoers_file"
}

require_macos() {
	if [[ "$(uname -s)" != "Darwin" ]]; then
		echo "This script only supports macOS." >&2
		exit 1
	fi
}

install_homebrew() {
	if command -v brew >/dev/null 2>&1; then
		return
	fi

	log "Installing Homebrew"
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

init_homebrew() {
	if [[ -x /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -x /usr/local/bin/brew ]]; then
		eval "$(/usr/local/bin/brew shellenv)"
	else
		echo "Homebrew was not found after installation." >&2
		exit 1
	fi
}

ensure_taps() {
	local taps=(
		anomalyco/tap
		oven-sh/bun
		philocalyst/tap
		steipete/tap
		xykong/tap
	)

	log "Adding required taps"
	for tap in "${taps[@]}"; do
		if brew tap | grep -Fxq "$tap"; then
			printf 'Already tapped: %s\n' "$tap"
			continue
		fi

		brew tap "$tap"
	done
}

install_formulae() {
	log "Installing Homebrew formulae"
	for package in "${formulae[@]}"; do
		if brew list "$package" >/dev/null 2>&1; then
			printf 'Already installed: %s\n' "$package"
			continue
		fi

		brew install "$package"
	done
}

install_casks() {
	log "Installing Homebrew casks"
	for package in "${casks[@]}"; do
		if brew list --cask "$package" >/dev/null 2>&1; then
			printf 'Already installed: %s\n' "$package"
			continue
		fi

		brew install --cask "$package"
	done
}

configure_macos_defaults() {
	log "Configuring macOS defaults"
	defaults write com.apple.dock autohide -bool true
	defaults write com.apple.dock autohide-delay -float 0
	defaults write com.apple.dock autohide-time-modifier -float 0.5
	defaults write com.apple.dock persistent-apps -array
	killall Dock >/dev/null 2>&1 || true
}

install_config_dir() {
	local source_dir="$SCRIPT_DIR/.config"
	local target_dir="$HOME/.config"
	local manifest_file="$target_dir/.mbp-managed-entries"
	local source_path entry target_path previous_entry
	local current_entries=()

	if [[ ! -d "$source_dir" ]]; then
		return
	fi

	mkdir -p "$target_dir"

	shopt -s nullglob dotglob
	for source_path in "$source_dir"/*; do
		entry="${source_path##*/}"

		if [[ "$entry" == ".DS_Store" ]]; then
			continue
		fi

		current_entries+=("$entry")
		target_path="$target_dir/$entry"

		if [[ -d "$source_path" ]]; then
			mkdir -p "$target_path"
			rsync -a --delete --exclude '.DS_Store' "$source_path/" "$target_path/"
		else
			rsync -a --exclude '.DS_Store' "$source_path" "$target_path"
		fi
	done
	shopt -u nullglob dotglob

	if [[ -f "$manifest_file" ]]; then
		while IFS= read -r previous_entry; do
			local is_current=0
			local current_entry

			if [[ -z "$previous_entry" ]]; then
				continue
			fi

			for current_entry in "${current_entries[@]}"; do
				if [[ "$current_entry" == "$previous_entry" ]]; then
					is_current=1
					break
				fi
			done

			if [[ "$is_current" -eq 0 ]]; then
				rm -rf "$target_dir/$previous_entry"
			fi
		done < "$manifest_file"
	fi

	printf '%s\n' "${current_entries[@]}" > "$manifest_file"
	log "Installed .config to $target_dir"
}

install_zshrc() {
	local source_file="$SCRIPT_DIR/.zshrc"
	local target_file="$HOME/.zshrc"
	local backup_file="$HOME/.zshrc.pre-mbp.backup"

	if [[ ! -f "$source_file" ]]; then
		return
	fi

	if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
		log ".zshrc already matches repo copy"
		return
	fi

	if [[ -f "$target_file" ]]; then
		if [[ ! -f "$backup_file" ]]; then
			cp "$target_file" "$backup_file"
			log "Backed up existing .zshrc to $backup_file"
		else
			log "Preserving existing .zshrc backup at $backup_file"
		fi
	fi

	cp "$source_file" "$target_file"
	log "Installed .zshrc to $target_file"
}

install_hushlogin() {
	local target_file="$HOME/.hushlogin"

	if [[ -f "$target_file" ]]; then
		log ".hushlogin already exists"
		return
	fi

	touch "$target_file"
	log "Created $target_file"
}

install_vscode_settings() {
	local source_file="$SCRIPT_DIR/vscode/settings.json"
	local target_dir="$HOME/Library/Application Support/Code/User"
	local target_file="$target_dir/settings.json"
	local backup_file="$target_dir/settings.json.pre-mbp.backup"

	if [[ ! -f "$source_file" ]]; then
		return
	fi

	mkdir -p "$target_dir"

	if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
		log "VS Code settings already match repo copy"
		return
	fi

	if [[ -f "$target_file" ]]; then
		if [[ ! -f "$backup_file" ]]; then
			cp "$target_file" "$backup_file"
			log "Backed up existing VS Code settings to $backup_file"
		else
			log "Preserving existing VS Code settings backup at $backup_file"
		fi
	fi

	cp "$source_file" "$target_file"
	log "Installed VS Code settings to $target_file"
}

install_vscode_extensions() {
	local installed_extensions extension code_cmd

	if command -v code >/dev/null 2>&1; then
		code_cmd="$(command -v code)"
	elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
		code_cmd="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
	else
		log "Skipping VS Code extensions because the VS Code CLI is unavailable"
		return
	fi

	installed_extensions="$("$code_cmd" --list-extensions 2>/dev/null || true)"

	log "Installing VS Code extensions"
	for extension in "${vscode_extensions[@]}"; do
		if printf '%s\n' "$installed_extensions" | grep -Fxq "$extension"; then
			printf 'Already installed: %s\n' "$extension"
			continue
		fi

		"$code_cmd" --install-extension "$extension"
		installed_extensions="${installed_extensions}"$'\n'"$extension"
	done
}

main() {
	require_macos
	configure_passwordless_sudo
	install_homebrew
	init_homebrew

	log "Updating Homebrew metadata"
	brew update

	ensure_taps
	install_formulae
	install_casks
	install_vscode_settings
	install_vscode_extensions
	install_config_dir
	install_zshrc
	install_hushlogin
	configure_macos_defaults

	log "Setup complete"
	echo "Open a new terminal session or run: exec zsh"
}

main "$@"
