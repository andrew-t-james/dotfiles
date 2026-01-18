#!/usr/bin/env bash
#
# setup-web-apps.sh - Install web app desktop entries and icons
#
# This script copies .desktop files and icons from the dotfiles repo to the
# user's ~/.local/share/applications directory. It replaces __HOME__ placeholders
# with the actual home directory path, making the dotfiles portable across machines.
#
# Usage:
#   ./setup-web-apps.sh              # Install for current user
#   ./setup-web-apps.sh --dry-run    # Preview changes without writing
#   ./setup-web-apps.sh --user foo   # Install for a specific user
#
# What it does:
#   1. Copies all .desktop files from web-apps/ to ~/.local/share/applications/
#   2. Copies all icons from web-apps/icons/ to ~/.local/share/applications/icons/
#   3. Replaces __HOME__ placeholder with actual home directory in .desktop files
#   4. Updates the desktop database so apps appear in launchers
#   5. Sets shortwave-mailto.desktop as the default mailto: handler
#
# Dependencies:
#   - update-desktop-database (optional, for refreshing app menus)
#   - For mailto handler: jq, hyprctl, wtype (see scripts/shortwave-mailto.sh)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SRC_DIR="$SCRIPT_DIR/web-apps"
SRC_ICON_DIR="$SRC_DIR/icons"

DRY_RUN=0
USER_NAME=""

usage() {
  cat <<EOF
Usage:
  $(basename "$0") [--dry-run] [--user USERNAME]

Options:
  --dry-run        Print actions without writing files
  --user USERNAME  Install for a specific user (default: current user)
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --user) USER_NAME="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

# Default to current user if not specified
if [[ -z "${USER_NAME}" ]]; then
  USER_NAME="$(id -un)"
fi

# Resolve home directory from passwd database (works for any user)
HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
if [[ -z "$HOME_DIR" ]]; then
  echo "Could not resolve home directory for user: $USER_NAME" >&2
  exit 1
fi

DST_APPS="$HOME_DIR/.local/share/applications"
DST_ICONS="$DST_APPS/icons"

echo "User:       $USER_NAME"
echo "Home:       $HOME_DIR"
echo "Source:     $SRC_DIR"
echo "Dest apps:  $DST_APPS"
echo "Dest icons: $DST_ICONS"
echo

# Verify source directory exists
if [[ ! -d "$SRC_DIR" ]]; then
  echo "Missing source dir: $SRC_DIR" >&2
  exit 1
fi

# Create destination directories
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] mkdir -p '$DST_APPS' '$DST_ICONS'"
else
  mkdir -p "$DST_APPS" "$DST_ICONS"
fi

# Copy all icons from web-apps/icons/ to ~/.local/share/applications/icons/
if [[ -d "$SRC_ICON_DIR" ]]; then
  for icon in "$SRC_ICON_DIR"/*; do
    [[ -f "$icon" ]] || continue
    icon_name="$(basename "$icon")"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] cp '$icon' -> '$DST_ICONS/$icon_name'"
    else
      cp -f "$icon" "$DST_ICONS/$icon_name"
    fi
  done
fi

# Copy .desktop files, replacing __HOME__ with actual home directory
# This allows the same dotfiles to work on any machine regardless of username
for desktop in "$SRC_DIR"/*.desktop; do
  [[ -f "$desktop" ]] || continue
  desktop_name="$(basename "$desktop")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] render: $desktop -> $DST_APPS/$desktop_name (replace __HOME__ with $HOME_DIR)"
  else
    sed "s|__HOME__|$HOME_DIR|g" "$desktop" > "$DST_APPS/$desktop_name"
    chmod 0644 "$DST_APPS/$desktop_name"
  fi
done

# Update desktop database so new apps appear in application launchers
if command -v update-desktop-database >/dev/null 2>&1; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] update-desktop-database '$DST_APPS'"
  else
    update-desktop-database "$DST_APPS" >/dev/null 2>&1 || true
  fi
else
  echo "Note: update-desktop-database not found; skipping."
fi

# Set shortwave-mailto.desktop as the default handler for mailto: links
# This is done by editing ~/.config/mimeapps.list directly because xdg-mime
# can be unreliable when multiple apps claim the same mime type
MIMEAPPS="$HOME_DIR/.config/mimeapps.list"
if [[ -f "$DST_APPS/shortwave-mailto.desktop" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] Set x-scheme-handler/mailto=shortwave-mailto.desktop in $MIMEAPPS"
  else
    mkdir -p "$(dirname "$MIMEAPPS")"
    if [[ ! -f "$MIMEAPPS" ]]; then
      echo "[Default Applications]" > "$MIMEAPPS"
    fi
    # Remove any existing mailto entry to avoid duplicates
    tmp="$(mktemp)"
    grep -v '^x-scheme-handler/mailto=' "$MIMEAPPS" > "$tmp" || true
    # Add the mailto handler under [Default Applications] section
    if grep -q '^\[Default Applications\]' "$tmp"; then
      sed -i '/^\[Default Applications\]/a x-scheme-handler/mailto=shortwave-mailto.desktop' "$tmp"
    else
      echo -e "[Default Applications]\nx-scheme-handler/mailto=shortwave-mailto.desktop" | cat - "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
    fi
    mv "$tmp" "$MIMEAPPS"
  fi
fi

echo
echo "Done."
