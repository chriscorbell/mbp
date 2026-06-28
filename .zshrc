# Initialize Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# History/completion basics
autoload -Uz compinit
compinit

# Environment
export EDITOR=nano
export VISUAL=code
export PAGER=less
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Aliases
alias in='brew install'
alias un='brew uninstall'
alias up='brew update && brew upgrade'
alias grep='grep --color=auto'
alias claude='claude --dangerously-skip-permissions'
alias codex='codex --yolo'
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gb='git branch'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias cat='bat --theme ansi -pp'
alias ls='eza -al --header --git --icons=always'
alias lg='lazygit'
alias ld='lazydocker'

# Git add/commit/push current branch
gacp() {
  git add .
  git commit -m "$*"
  branch=$(git rev-parse --abbrev-ref HEAD) || return 1
  git push origin "$branch"
}

# Plugins
eval "$(starship init zsh)"
eval "$(atuin init zsh)"
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/chris/.docker/completions $fpath)
# End of Docker CLI completions

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/chris/.lmstudio/bin"
# End of LM Studio CLI section

