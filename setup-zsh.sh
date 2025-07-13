#!/usr/bin/env bash
set -euo pipefail

ZSHRC="$HOME/.zshrc"

cat >"$ZSHRC" <<'EOF'
# -------------------- XDG Base --------------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# -------------------- PATH Setup --------------------
unset DYLD_LIBRARY_PATH
typeset -aU path
path=(
  "$HOME/.local/share/mise/shims"
  "$HOME/.local/share/omarchy/bin"
  "$HOME/.local/bin"
  "$HOME/.bun/bin"
  "$HOME/go/bin"
  /usr/local/bin
  /usr/bin
  /bin
)
[[ -d /opt/homebrew/bin ]] && path+=("/opt/homebrew/bin")
[[ -d /opt/homebrew/sbin ]] && path+=("/opt/homebrew/sbin")
export PATH

# -------------------- Oh My Zsh --------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
source "$ZSH/oh-my-zsh.sh"

# -------------------- Antigen --------------------
ANTIGEN_PATH="$ZDOTDIR/antigen.zsh"
[[ -f "$ANTIGEN_PATH" ]] && source "$ANTIGEN_PATH"

antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zdharma-continuum/fast-syntax-highlighting
antigen bundle paulirish/git-open
antigen bundle jeffreytse/zsh-vi-mode
antigen apply

# -------------------- Shell Behavior --------------------
[[ -n $TMUX ]] && export TERM=xterm-256color
export GPG_TTY=$(tty)

# -------------------- Tool Initializations --------------------
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# -------------------- Aliases & Functions --------------------
[[ -f "$ZDOTDIR/alias.sh" ]] && source "$ZDOTDIR/alias.sh"
[[ -f "$ZDOTDIR/functions.sh" ]] && source "$ZDOTDIR/functions.sh"
EOF

echo "[INFO] ~/.zshrc written successfully."
