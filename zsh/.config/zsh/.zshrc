# ---------------- PATH SETUP ----------------
unset DYLD_LIBRARY_PATH

typeset -aU path
path+=(
  "$HOME/.local/share/mise/shims"        # mise-managed tools like node
  "$HOME/.local/share/omarchy/bin"       # omarchy scripts
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  /usr/local/bin
  /usr/bin
  /bin
)

# macOS-specific
[[ -d /opt/homebrew/bin ]] && path+=("/opt/homebrew/bin")
[[ -d /opt/homebrew/sbin ]] && path+=("/opt/homebrew/sbin")

export PATH

# Add macOS-specific paths if present
[[ -d /opt/homebrew/bin ]] && path+=("/opt/homebrew/bin")
[[ -d /opt/homebrew/sbin ]] && path+=("/opt/homebrew/sbin")

export PATH="$HOME/.local/share/omarchy/bin:$PATH"
export PATH

# ---------------- Aliases ----------------
[[ -f "$HOME/.config/zsh/alias.sh" ]] && source "$HOME/.config/zsh/alias.sh"

# ---------------- ZSH Theme ----------------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="robbyrussell"

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

# ---------------- Prompt ----------------
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
fi

# ---------------- Navigation & Tools ----------------
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v mise &>/dev/null && eval "$(mise activate zsh)"

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# ---------------- Development Environments ----------------
[[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]] && source "/opt/homebrew/opt/asdf/libexec/asdf.sh"

# ---------------- Local Environment Overrides ----------------
[[ -f "$HOME/bin/env" ]] && source "$HOME/bin/env"
