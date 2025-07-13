#!/usr/bin/env bash
set -euo pipefail

ZSHRC="$HOME/.zshrc"
ZDOTDIR="$HOME/.config/zsh"

# -------------------- Install Zsh if not present --------------------
if ! command -v zsh &>/dev/null; then
  echo "[INFO] Installing zsh..."
  if command -v apt &>/dev/null; then
    sudo apt install -y zsh
  elif command -v brew &>/dev/null; then
    brew install zsh
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm zsh
  else
    echo "[ERROR] Package manager not found. Please install zsh manually."
    exit 1
  fi
fi

# -------------------- Create ZDOTDIR if it doesn't exist --------------------
mkdir -p "$ZDOTDIR"

# -------------------- Install Oh My Zsh --------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "[INFO] Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# -------------------- Install Antigen --------------------
if [[ ! -f "$ZDOTDIR/antigen.zsh" ]]; then
  echo "[INFO] Installing Antigen..."
  curl -L git.io/antigen >"$ZDOTDIR/antigen.zsh"
fi

# -------------------- Write .zshrc --------------------
cat >"$ZSHRC" <<'EOF'
# -------------------- Hyprland Autostart ----------------
if command -v Hyprland >/dev/null && [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec Hyprland
fi

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

# -------------------- Change Shell to Zsh --------------------
if [[ "$SHELL" != *"zsh"* ]]; then
  echo "[INFO] Changing default shell to zsh..."
  ZSH_PATH=$(command -v zsh)
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "[INFO] Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
  echo "[INFO] Shell changed to zsh. Please log out and log back in for changes to take effect."
fi

echo "[INFO] Setup complete!"
