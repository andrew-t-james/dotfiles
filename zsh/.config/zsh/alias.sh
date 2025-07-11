#!/bin/bash

# ====================
# Environment Variables
# ====================
export LAUNCH_EDITOR="nvim"
export EDITOR="nvim"
export GIT_EDITOR="nvim"
export VISUAL="nvim"

GPG_TTY=$(tty)
export GPG_TTY

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
alias git-clone-worktree='~/.config/zsh/clone-worktree.sh'
alias gcw='git-clone-worktree'
alias envrc='echo '\''source "${HOME}/.config/env/.envrc"'\'' > .envrc && direnv allow .'

# Kubernetes
alias k='kubectl'

# ====================
# System Utilities
# ====================
# Modern replacements for traditional tools
alias cat=bat    # Modern replacement for cat
alias diff=delta # Modern replacement for diff

# System monitoring
alias sleepless="pmset -g assertions | egrep '(PreventUserIdleSystemSleep|PreventUserIdleDisplaySleep)'" # Check sleep preventing processes

# ====================
# Tmux Configuration
# ====================
alias tmux='tmux -f ~/.config/tmux/tmux.conf'                                                     # Use custom tmux config
alias kt='killall tmux'                                                                           # Kill all tmux sessions
alias lo='tmux list-windows -F "#{window_active} #{window_layout}" | grep "^1" | cut -d " " -f 2' # List active window layouts

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
