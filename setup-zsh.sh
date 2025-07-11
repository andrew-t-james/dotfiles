#!/usr/bin/env bash
set -euo pipefail

# -------------------- OS Detection --------------------
OS="$(uname -s)"
echo "[INFO] Detected OS: $OS"

# -------------------- Install zsh --------------------
echo "[INFO] Installing zsh..."
if [[ "$OS" == "Linux" ]]; then
  sudo pacman -Syu --noconfirm zsh
elif [[ "$OS" == "Darwin" ]]; then
  brew install zsh
else
  echo "[ERROR] Unsupported OS: $OS"
  exit 1
fi

# -------------------- Install Antigen --------------------
ANTIGEN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
ANTIGEN_FILE="$ANTIGEN_DIR/antigen.zsh"

if [[ -f "$ANTIGEN_FILE" ]]; then
  echo "[INFO] Antigen already installed at $ANTIGEN_FILE"
else
  echo "[INFO] Installing Antigen to $ANTIGEN_FILE"
  mkdir -p "$ANTIGEN_DIR"
  curl -L git.io/antigen >"$ANTIGEN_FILE"
fi

# -------------------- Install Oh My Zsh --------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "[INFO] Installing Oh My Zsh..."
  unset ZSH
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "[INFO] Oh My Zsh installed successfully."
else
  echo "[INFO] Oh My Zsh already installed at $HOME/.oh-my-zsh, skipping install."
fi

# -------------------- Write Complete .zshrc --------------------
ZSHRC="$HOME/.zshrc"
echo "[INFO] Writing full ~/.zshrc..."

cat >"$ZSHRC" <<'EOF'
# -------------------- Path Management --------------------
typeset -U path
path=(
    /opt/homebrew/bin
    /opt/homebrew/sbin
    /usr/local/bin
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/go/bin"
    "$XDG_DATA_HOME/pnpm"
    $path
)
export PATH

# -------------------- Oh My Zsh --------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
source "$ZSH/oh-my-zsh.sh"

# -------------------- Antigen --------------------
# Path to your zsh config directory
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Antigen
source "$ZDOTDIR/antigen.zsh"

antigen use oh-my-zsh
antigen bundles <<EOBUNDLES
    git
    zsh-users/zsh-autosuggestions
    zdharma-continuum/fast-syntax-highlighting
    paulirish/git-open
    jeffreytse/zsh-vi-mode
EOBUNDLES
antigen apply

# -------------------- Custom Aliases & Functions --------------------
source "$ZDOTDIR/alias.sh"
source "$ZDOTDIR/functions.sh"

# -------------------- Tool Initializations --------------------
[[ -n $TMUX ]] && export TERM=xterm-256color
export YSU_HARDCORE=1
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export GPG_TTY=$(tty)

# -------------------- Prompts & Tools --------------------
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"
eval "$(zoxide init zsh --cmd z)"
eval "$(direnv hook zsh)"
EOF

echo "[INFO] ~/.zshrc written successfully."

# -------------------- Change Default Shell --------------------
echo "[INFO] Setting zsh as default shell (using sudo)..."
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  sudo chsh -s "$ZSH_PATH" "$USER"
  echo "[INFO] Default shell changed to zsh. Re-login for changes to take effect."
else
  echo "[INFO] zsh is already the default shell."
fi

# -------------------- Hyprland Auto-start (Linux Only) --------------------
if [[ "$OS" == "Linux" ]]; then
  ZPROFILE="$HOME/.zprofile"
  HYPRLAND_AUTO_START=$(
    cat <<'EOF'
if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec Hyprland
fi
EOF
  )

  [[ -f "$ZPROFILE" ]] || touch "$ZPROFILE"

  if grep -q "exec Hyprland" "$ZPROFILE"; then
    echo "[INFO] Hyprland auto-start already configured in ~/.zprofile"
  else
    echo "$HYPRLAND_AUTO_START" >>"$ZPROFILE"
    echo "[INFO] Hyprland auto-start block added to ~/.zprofile"
  fi
else
  echo "[INFO] Skipping Hyprland auto-start (macOS detected)"
fi

echo "[INFO] Zsh setup complete. Reload your shell with: source ~/.zshrc"
