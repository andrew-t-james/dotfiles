#!/bin/bash

# ====================
# Environment Variables
# ====================
export LAUNCH_EDITOR="nvim"
export EDITOR="nvim"
export GIT_EDITOR="nvim"
export VISUAL="nvim"

export GPG_TTY="${TTY:-$(tty)}"

# ====================
# Navigation Shortcuts
# ====================
alias work="cd ~/repos"
alias conf="cd ~/.config"
alias desk="cd ~/Desktop"

# ====================
# Docker Management
# ====================
alias dc='docker compose'

# ====================
# Package Management
# ====================
# NPM related
alias npml='npm list -g --depth=0'     # List global packages
alias npmo='npm outdated -g --depth=0' # Check outdated global packages
alias npmu='npm-check -gu'             # Interactive update tool for global packages

# Homebrew
alias brewup='brew update; brew upgrade; brew cleanup; brew cleanup; brew doctor' # Update and maintain brew

# ====================
# Development Tools
# ====================
# Git related
alias acm='git diff | pbcopy && open "raycast://ai-commands/git-commit-message"' # Copy git diff and open Raycast
alias cw='clone_worktree'
alias envrc='echo '\''source "${HOME}/.config/env/.envrc"'\'' > .envrc && direnv allow .'
alias cr='clear'
alias aistatus='~/.config/zsh/ai-status.sh'

# Kubernetes
alias k='kubectl'

# ====================
# System Utilities
# ====================
# Modern replacements for traditional tools
alias cat=bat    # Modern replacement for cat
alias top=btop   # Modern replacement for top
alias diff=delta # Modern replacement for diff
alias ll='exa -l --git --icons'
alias la='exa -la --icons'
alias lt='exa --tree --level=2 --icons'

# System monitoring
alias sleepless="pmset -g assertions | egrep '(PreventUserIdleSystemSleep|PreventUserIdleDisplaySleep)'" # Check sleep preventing processes

# ====================
# Tmux Configuration
# ====================
alias tmux='tmux -f ~/.config/tmux/tmux.conf attach 2>/dev/null || tmux -f ~/.config/tmux/tmux.conf' # Attach or create
alias kt='killall tmux'                                                                              # Kill all tmux sessions
alias lo='tmux list-windows -F "#{window_active} #{window_layout}" | grep "^1" | cut -d " " -f 2'    # List active window layouts

# ====================
# Commented Out (Reference)
# ====================
#alias fnm='find . -name "node_modules" -type d -prune -print | xargs du -chs'        # Find and show node_modules sizes
#alias dnm='find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;'   # Delete all node_modules

# ====================
# Python Environment
# ====================
alias pip=pip3       # use pip3 as default pip command
alias python=python3 # use python3 as default python command

# ====================
# AI Tools
# ====================
alias yolo='claude --dangerously-skip-permissions'
alias cdx='codex --dangerously-bypass-approvals-and-sandbox'

# dmux wrapper — works around send-keys race condition (standardagents/dmux#84)
# Runs dmux directly as the pane process, bypassing shell init entirely
dmux() {
  local pn ph sn dmux_bin
  pn="$(basename "$(pwd)")"
  ph="$(printf '%s' "$(pwd)" | md5 | cut -c1-8)"
  sn="dmux-${pn//./-}-${ph}"
  dmux_bin="$(command -v dmux)"

  if tmux has-session -t "$sn" 2>/dev/null; then
    command dmux "$@"
  else
    tmux new-session -d -s "$sn" "$dmux_bin"
    sleep 0.5
    tmux attach-session -t "$sn"
  fi
}

# ====================
# Whatsapp tui be
# ====================
waha() {
  local _env_file _api_key
  _env_file="$HOME/.config/waha-tui/.env"

  if [[ ! -f "$_env_file" ]]; then
    echo "waha: missing $_env_file" >&2
    return 1
  fi

  _api_key="$(command grep '^WAHA_API_KEY=' "$_env_file" | cut -d= -f2-)"
  if [[ -z "$_api_key" ]]; then
    echo "waha: WAHA_API_KEY not found in $_env_file" >&2
    return 1
  fi

  docker run -d -p 9876:3000 -v waha-data:/app/.sessions -e "WHATSAPP_API_KEY=$_api_key" devlikeapro/waha
}

# Load local/work aliases (not tracked in git)
# Load local/work aliases (not tracked in git)
if [[ -f ~/.config/zsh/.aliases.local.sh ]]; then
  source ~/.config/zsh/.aliases.local.sh
fi
