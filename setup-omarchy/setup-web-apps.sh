#!/usr/bin/env bash
# Copies web app .desktop files and sets up mailto handler
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/web-apps"
SRC_ICON_DIR="$SRC_DIR/icons"
DST_APPS="$HOME/.local/share/applications"
DST_ICONS="$DST_APPS/icons"
MIMEAPPS="$HOME/.config/mimeapps.list"

APPLY=false
[[ ${1:-} == "--apply" ]] && APPLY=true

[[ -d "$SRC_DIR" ]] || { echo "[INFO] No web-apps directory, skipping"; exit 0; }

if $APPLY; then
  mkdir -p "$DST_APPS" "$DST_ICONS"

  # Copy icons
  for icon in "$SRC_ICON_DIR"/*; do
    [[ -f "$icon" ]] || continue
    cp -f "$icon" "$DST_ICONS/"
  done

  # Copy .desktop files, replacing __HOME__
  for desktop in "$SRC_DIR"/*.desktop; do
    [[ -f "$desktop" ]] || continue
    sed "s|__HOME__|$HOME|g" "$desktop" > "$DST_APPS/$(basename "$desktop")"
  done

  # Update desktop database
  update-desktop-database "$DST_APPS" 2>/dev/null || true

  # Set mailto handler if shortwave-mailto.desktop exists
  if [[ -f "$DST_APPS/shortwave-mailto.desktop" ]]; then
    mkdir -p "$(dirname "$MIMEAPPS")"
    [[ -f "$MIMEAPPS" ]] || echo "[Default Applications]" > "$MIMEAPPS"
    tmp="$(mktemp)"
    grep -v '^x-scheme-handler/mailto=' "$MIMEAPPS" > "$tmp" || true
    sed -i '/^\[Default Applications\]/a x-scheme-handler/mailto=shortwave-mailto.desktop' "$tmp"
    mv "$tmp" "$MIMEAPPS"
  fi

  echo "[INFO] Installed web apps to $DST_APPS"
else
  echo "[DRY RUN] Would copy .desktop files from $SRC_DIR to $DST_APPS"
  echo "[DRY RUN] Would set mailto handler to shortwave-mailto.desktop"
fi
