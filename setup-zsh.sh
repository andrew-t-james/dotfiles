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

# -------------------- Change default shell --------------------
echo "[INFO] Setting zsh as default shell..."
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  chsh -s "$ZSH_PATH"
  echo "[INFO] Default shell changed to zsh. Re-login for changes to take effect."
else
  echo "[INFO] zsh is already the default shell."
fi

# -------------------- Update ~/.zshrc --------------------
ZSHRC="$HOME/.zshrc"
OMARCHY_BIN='export PATH="$HOME/.local/share/omarchy/bin:$PATH"'
OMARCHY_ALIAS_SOURCE='source ~/.local/share/omarchy/default/bash/rc'

echo "[INFO] Configuring ~/.zshrc..."
[[ -f "$ZSHRC" ]] || touch "$ZSHRC"

# Add Omarchy bin path
if grep -Fxq "$OMARCHY_BIN" "$ZSHRC"; then
  echo "[INFO] Omarchy bin directory already present in ~/.zshrc"
else
  echo "$OMARCHY_BIN" >>"$ZSHRC"
  echo "[INFO] Added Omarchy bin directory to PATH in ~/.zshrc"
fi

# Source Omarchy bash rc
if grep -Fxq "$OMARCHY_ALIAS_SOURCE" "$ZSHRC"; then
  echo "[INFO] Omarchy bash aliases already sourced in ~/.zshrc"
else
  echo "$OMARCHY_ALIAS_SOURCE" >>"$ZSHRC"
  echo "[INFO] Added Omarchy bash aliases to ~/.zshrc"
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

echo "[INFO] Setup complete. Reload your shell with: source ~/.zshrc"
