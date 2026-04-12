#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

formulae=(
	anomalyco/tap/opencode
	atuin
	bat
	bitwarden-cli
	btop
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
	iperf3
	iproute2mac
	jq
	just
	lazydocker
	lazygit
	llmfit
	make
	nano
	nanorc
	node
	npm
	oven-sh/bun/bun
	pnpm
	python
	rclone
	ripgrep
	starship
	uv
	volta
	watchexec
	yarn
	yq
	zsh-autosuggestions
	zsh-syntax-highlighting
)

casks=(
	adobe-creative-cloud
	affinity
	bambu-studio
	betterdisplay
	bitwarden
	caffeine
	chatgpt
	claude
	claude-code@latest
	codex
	codex-app
	discord
	dockdoor
	docker-desktop
	ente-auth
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
	microsoft-powerpoint
	microsoft-teams
	microsoft-word
	moonlight
	motu-m-series
	obs
	opencode-desktop
	proton-mail
	raycast
	rectangle
	steam
	codexbar
	stremio
	tailscale-app
	telegram
	windows-app
	visual-studio-code
	wispr-flow
	zen
	zoom
)

log() {
	printf '\n==> %s\n' "$1"
}

configure_passwordless_sudo() {
	local username sudoers_dir sudoers_file temp_file sudoers_line

	username="$(id -un)"
	sudoers_dir="/etc/sudoers.d"
	sudoers_file="$sudoers_dir/mbp-$username"
	sudoers_line="$username ALL=(ALL) NOPASSWD: ALL"
	temp_file="$(mktemp)"

	trap 'rm -f "$temp_file"' RETURN

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
		homebrew/cask-fonts
		oven-sh/bun
		steipete/tap
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

install_config_dir() {
	local source_dir="$SCRIPT_DIR/.config"
	local target_dir="$HOME/.config"

	if [[ ! -d "$source_dir" ]]; then
		return
	fi

	mkdir -p "$target_dir"
	rsync -a --exclude '.DS_Store' "$source_dir/" "$target_dir/"
	log "Installed .config to $target_dir"
}

install_zshrc() {
	local source_file="$SCRIPT_DIR/.zshrc"
	local target_file="$HOME/.zshrc"
	local backup_file

	if [[ ! -f "$source_file" ]]; then
		return
	fi

	if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
		log ".zshrc already matches repo copy"
		return
	fi

	if [[ -f "$target_file" ]]; then
		backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
		cp "$target_file" "$backup_file"
		log "Backed up existing .zshrc to $backup_file"
	fi

	cp "$source_file" "$target_file"
	log "Installed .zshrc to $target_file"
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
	install_config_dir
	install_zshrc

	log "Setup complete"
	echo "Open a new terminal session or run: exec zsh"
}

main "$@"