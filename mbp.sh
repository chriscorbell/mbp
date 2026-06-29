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
	mas
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
	balenaetcher
	bambu-studio
	betterdisplay
	bitwarden
	caffeine
	chatgpt
	claude
	claude-code@latest
	cloudmounter
	cmux
	codex
	codex-app
	codexbar
	comfy
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
	icon-composer
	ilok-license-manager
	jordanbaird-ice
	lm-studio
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
	ollama-app
	opencode-desktop
	siddharthvaddem/openscreen/openscreen
	orbstack
	parsec
	pika
	proton-mail
	raspberry-pi-imager
	raycast
	rectangle
	stats
	steam
	stremio
	superwhisper
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

mas_apps=(
	"425264550:Disk Speed Test"
)

vscode_extensions=(
	anthropic.claude-code
	budparr.language-hugo-vscode
	dbaeumer.vscode-eslint
	ecmel.vscode-html-css
	esbenp.prettier-vscode
	github.vscode-github-actions
	golang.go
	huggingface.huggingface-vscode-chat
	ms-azuretools.vscode-containers
	ms-playwright.playwright
	ms-vscode-remote.remote-containers
	ms-vscode-remote.remote-ssh
	ms-vscode-remote.remote-ssh-edit
	ms-vscode.live-server
	ms-vscode.remote-explorer
	ms-vscode.vscode-chat-customizations-evaluations
	openai.chatgpt
	redhat.vscode-yaml
	shd101wyy.markdown-preview-enhanced
	tamasfe.even-better-toml
)

log() {
	printf '\n==> %s\n' "$1"
}

set_pmset() {
	local power_source setting value

	power_source="$1"
	setting="$2"
	value="$3"

	if ! sudo pmset "$power_source" "$setting" "$value"; then
		printf 'Skipping unsupported pmset setting: %s %s %s\n' "$power_source" "$setting" "$value"
	fi
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
		siddharthvaddem/openscreen
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

cask_already_present() {
	local package="$1"

	case "$package" in
		balenaetcher)
			[[ -e "/Applications/balenaEtcher.app" ]]
			;;
		cloudmounter)
			[[ -e "/Applications/CloudMounter.app" ]]
			;;
		cmux)
			[[ -e "/Applications/cmux.app" ]]
			;;
		comfy)
			[[ -e "/Applications/ComfyUI.app" || -e "/Applications/Comfy Desktop.app" ]]
			;;
		icon-composer)
			[[ -e "/Applications/Icon Composer.app" ]]
			;;
		lm-studio)
			[[ -e "/Applications/LM Studio.app" ]]
			;;
		ollama-app)
			[[ -e "/Applications/Ollama.app" ]]
			;;
		siddharthvaddem/openscreen/openscreen)
			[[ -e "/Applications/Openscreen.app" ]]
			;;
		parsec)
			[[ -e "/Applications/Parsec.app" ]]
			;;
		superwhisper)
			[[ -e "/Applications/superwhisper.app" ]]
			;;
		*)
			return 1
			;;
	esac
}

install_casks() {
	log "Installing Homebrew casks"
	for package in "${casks[@]}"; do
		if brew list --cask "$package" >/dev/null 2>&1; then
			printf 'Already installed: %s\n' "$package"
			continue
		fi

		if cask_already_present "$package"; then
			printf 'Already present outside Homebrew: %s\n' "$package"
			continue
		fi

		brew install --cask "$package"
	done
}

install_mas_apps() {
	local installed_app_ids app app_id app_name

	if [[ "${#mas_apps[@]}" -eq 0 ]]; then
		return
	fi

	if ! command -v mas >/dev/null 2>&1; then
		log "Skipping Mac App Store apps because mas is unavailable"
		return
	fi

	if ! mas account >/dev/null 2>&1; then
		log "Skipping Mac App Store apps because the App Store is not signed in"
		return
	fi

	installed_app_ids="$(mas list | awk '{print $1}')"

	log "Installing Mac App Store apps"
	for app in "${mas_apps[@]}"; do
		app_id="${app%%:*}"
		app_name="${app#*:}"

		if printf '%s\n' "$installed_app_ids" | grep -Fxq "$app_id"; then
			printf 'Already installed: %s (%s)\n' "$app_name" "$app_id"
			continue
		fi

		mas install "$app_id"
		installed_app_ids="${installed_app_ids}"$'\n'"$app_id"
	done
}

configure_macos_defaults() {
	log "Configuring macOS defaults"

	defaults write com.apple.batteryui.charging.mac com.apple.batteryui.charging.mac.prior.limit -int 80
	set_pmset -b powermode 0
	set_pmset -c powermode 2
	set_pmset -c displaysleep 0

	defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
	defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

	defaults write com.apple.menuextra.clock ShowSeconds -bool true
	defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true
	defaults -currentHost write com.apple.controlcenter Battery -int 8
	defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
	defaults -currentHost write com.apple.controlcenter Spotlight -int 8

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

	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	defaults write com.apple.finder AppleShowAllExtensions -bool true
	defaults write com.apple.finder ShowPathbar -bool true
	defaults write com.apple.finder ShowStatusBar -bool true

	defaults write NSGlobalDomain KeyRepeat -int 2
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false
	defaults write NSGlobalDomain NSSmartReplyEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

	log "Disable True Tone manually in System Settings > Displays; macOS does not expose a stable defaults key."

	killall Dock >/dev/null 2>&1 || true
	killall Finder >/dev/null 2>&1 || true
	killall SystemUIServer >/dev/null 2>&1 || true
	killall ControlCenter >/dev/null 2>&1 || true
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
	install_mas_apps
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
