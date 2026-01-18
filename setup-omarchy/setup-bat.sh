#!/usr/bin/env bash
# Sets up Catppuccin theme for bat
set -euo pipefail

BAT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bat"
BAT_THEMES_DIR="$BAT_CONFIG_DIR/themes"

APPLY=false
[[ ${1:-} == "--apply" ]] && APPLY=true

BAT_SYNTAXES_DIR="$BAT_CONFIG_DIR/syntaxes"

if $APPLY; then
  mkdir -p "$BAT_THEMES_DIR" "$BAT_SYNTAXES_DIR"

  if [[ -d "$BAT_THEMES_DIR/catppuccin-bat" ]]; then
    git -C "$BAT_THEMES_DIR/catppuccin-bat" pull
  else
    git clone https://github.com/catppuccin/bat.git "$BAT_THEMES_DIR/catppuccin-bat"
  fi

  if compgen -G "$BAT_THEMES_DIR/catppuccin-bat/themes/*.tmTheme" >/dev/null; then
    cp "$BAT_THEMES_DIR/catppuccin-bat/themes/"*.tmTheme "$BAT_THEMES_DIR/"
  fi

  # Install syntaxes
  if [[ -d "$BAT_SYNTAXES_DIR/sublime-purescript-syntax" ]]; then
    git -C "$BAT_SYNTAXES_DIR/sublime-purescript-syntax" pull
  else
    git clone https://github.com/tellnobody1/sublime-purescript-syntax "$BAT_SYNTAXES_DIR/sublime-purescript-syntax"
  fi

  bat cache --build
  echo "[INFO] Set up Catppuccin theme for bat"
else
  echo "[DRY RUN] Would set up Catppuccin theme for bat"
fi
