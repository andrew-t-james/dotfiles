#!/usr/bin/env bash
set -euo pipefail

ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
mkdir -p "$ZDOTDIR"

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "[INFO] Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Antigen if not present
if [[ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/antigen.zsh" ]]; then
    echo "[INFO] Installing Antigen..."
    curl -L git.io/antigen > "${XDG_CONFIG_HOME:-$HOME/.config}/antigen.zsh"
fi

# Write main zsh configuration
cat > "$ZDOTDIR/.zshrc" <<'EOF'
# ---------------- Environment Setup ----------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# ---------------- PATH SETUP ----------------
unset DYLD_LIBRARY_PATH

typeset -aU path
path=(
  "$HOME/.local/share/mise/shims"
  "$HOME/.local/share/omarchy/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  /usr/local/bin
  /usr/bin
  /bin
)

# macOS-specific paths
[[ -d /opt/homebrew/bin ]] && path+=("/opt/homebrew/bin")
[[ -d /opt/homebrew/sbin ]] && path+=("/opt/homebrew/sbin")

export PATH

# ---------------- Oh My Zsh Configuration ----------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
source "$ZSH/oh-my-zsh.sh"

# ---------------- Antigen Plugin Manager ----------------
ANTIGEN_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/antigen.zsh"
if [[ -f "$ANTIGEN_PATH" ]]; then
  source "$ANTIGEN_PATH"

  antigen use oh-my-zsh

  # Core plugins
  antigen bundle git
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle zdharma-continuum/fast-syntax-highlighting
  antigen bundle jeffreytse/zsh-vi-mode

  antigen apply
fi

# ---------------- Terminal Settings ----------------
[[ -n "$TMUX" ]] && export TERM="xterm-256color"
command -v tty &>/dev/null && export GPG_TTY=$(tty)

# ---------------- Tool Initialization ----------------
# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
fi

# Additional tools
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# FZF
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# ---------------- Development Environments ----------------
[[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]] && source "/opt/homebrew/opt/asdf/libexec/asdf.sh"

# ---------------- Additional Configuration ----------------
# Aliases
[[ -f "$ZDOTDIR/alias.sh" ]] && source "$ZDOTDIR/alias.sh"

# Local environment overrides
[[ -f "$HOME/bin/env" ]] && source "$HOME/bin/env"
EOF

# Create .zshenv in home directory
cat > "$HOME/.zshenv" <<EOF
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
EOF

echo "[INFO] Zsh configuration complete!"
echo "[INFO] Please restart your shell or run 'source $HOME/.zshenv'"
