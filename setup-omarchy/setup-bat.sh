#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Setting up Catppuccin theme for bat"

# Detect bat config folder
BAT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bat"
BAT_THEMES_DIR="$BAT_CONFIG_DIR/themes"

mkdir -p "$BAT_THEMES_DIR"

# Clone the Catppuccin bat themes
if [[ -d "$BAT_THEMES_DIR/catppuccin-bat" ]]; then
  echo "[INFO] Catppuccin bat themes already cloned, updating..."
  git -C "$BAT_THEMES_DIR/catppuccin-bat" pull
else
  echo "[INFO] Cloning Catppuccin bat themes into $BAT_THEMES_DIR"
  git clone https://github.com/catppuccin/bat.git "$BAT_THEMES_DIR/catppuccin-bat"
fi

# Copy all .tmTheme files into bat's themes directory
if compgen -G "$BAT_THEMES_DIR/catppuccin-bat/themes/*.tmTheme" >/dev/null; then
  cp "$BAT_THEMES_DIR/catppuccin-bat/themes/"*.tmTheme "$BAT_THEMES_DIR/"
  echo "[INFO] Copied .tmTheme files into bat themes directory."
else
  echo "[WARN] No .tmTheme files found in catppuccin-bat repository!"
fi

# Rebuild bat cache
echo "[INFO] Rebuilding bat theme cache..."
bat cache --build

echo "[INFO] Done setting up Catppuccin theme for bat"
