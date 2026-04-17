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

if ! whence -w oc >/dev/null 2>&1; then
  oc() {
    if [ -z "${_OC_RUNNER_KIND:-}" ]; then
      if command -v opencode >/dev/null 2>&1; then
        _OC_RUNNER_KIND="opencode"
        _OC_RUNNER="opencode"
      elif command -v mise >/dev/null 2>&1; then
        local _oc_bin _oc_sh
        _oc_bin="$(mise which claude-max-proxy 2>/dev/null || true)"
        if [ -n "$_oc_bin" ]; then
          _oc_sh="$(dirname "$_oc_bin")/../lib/node_modules/opencode-claude-max-proxy/bin/oc.sh"
          if [ -x "$_oc_sh" ]; then
            _OC_RUNNER_KIND="shim"
            _OC_RUNNER="$_oc_sh"
          fi
        fi
      fi
    fi

    if [ "${_OC_RUNNER_KIND:-}" = "shim" ] && [ -x "${_OC_RUNNER:-}" ]; then
      "$_OC_RUNNER" "$@"
      return $?
    fi

    if [ "${_OC_RUNNER_KIND:-}" = "opencode" ]; then
      opencode "$@"
      return $?
    fi

    echo "oc: could not find oc shim or opencode binary" >&2
    return 127
  }
fi

if ! whence -w ocd >/dev/null 2>&1; then
  ocd() {
    local _base_url
    _base_url="${CLAUDE_PROXY_BASE_URL:-http://127.0.0.1:3456}"

    if ! command -v opencode >/dev/null 2>&1; then
      echo "ocd: opencode is not installed" >&2
      return 127
    fi

    if command -v curl >/dev/null 2>&1 \
      && [ "${OC_DISABLE_HEALTHCHECK:-0}" != "1" ] \
      && ! curl -sf --connect-timeout "${OC_HEALTHCHECK_CONNECT_TIMEOUT:-0.25}" --max-time "${OC_HEALTHCHECK_MAX_TIME:-0.75}" "$_base_url/health" >/dev/null 2>&1; then
      echo "ocd: proxy at $_base_url is not responding" >&2
      return 1
    fi

    ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-dummy}" \
    ANTHROPIC_BASE_URL="$_base_url" \
      opencode "$@"
  }
fi

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
