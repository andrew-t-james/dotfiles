#!/usr/bin/env bash
# Install OmaCal once and reconcile the default calendar on every apply.
set -euo pipefail

APPLY=false
[[ ${1:-} == "--apply" ]] && APPLY=true

OS="$(uname -s)"
ARCH="$(uname -m)"
case "$OS:$ARCH" in
  Linux:x86_64 | Linux:amd64 | Darwin:arm64) ;;
  *)
    echo "[INFO] OmaCal has no prebuilt release for $OS/$ARCH; skipping"
    exit 0
    ;;
esac

if ! $APPLY; then
  echo "[DRY RUN] Would install OmaCal if missing and make it the default calendar"
  exit 0
fi

BIN_DIR="$HOME/.local/bin"
if [[ "$OS" == "Linux" ]] && command -v omarchy >/dev/null 2>&1; then
  # The upstream AppImage requires FUSE2, which is not installed on every host.
  omarchy pkg add fuse2
fi

if [[ ! -x "$BIN_DIR/omacal" ]]; then
  INSTALLER="$(mktemp)"
  trap 'rm -f "$INSTALLER"' EXIT
  curl -fsSL https://omacal.app/install.sh -o "$INSTALLER"
  OMACAL_BIN_DIR="$BIN_DIR" sh "$INSTALLER"
fi

if [[ "$OS" == "Darwin" ]]; then
  # Existing Macs may have already run the one-time Homebrew bundle hook.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  if ! command -v duti >/dev/null 2>&1; then
    brew install duti
  fi
  # Register the downloaded bundle before selecting it in Launch Services.
  APP_BINARY="$(readlink "$BIN_DIR/omacal")"
  APP_BUNDLE="${APP_BINARY%/Contents/MacOS/omacal}"
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_BUNDLE"
  duti -s com.omacal.app .ics all
  if command -v aerospace >/dev/null 2>&1 && pgrep -x AeroSpace >/dev/null; then
    aerospace reload-config
  fi
else
  APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  mkdir -p "$APP_DIR"
  # The web installer omits file associations; match the release's desktop
  # entry so .ics files are actually passed to OmaCal for import.
  cat > "$APP_DIR/omacal.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=OmaCal
GenericName=Calendar
Exec="$BIN_DIR/omacal" %f
StartupWMClass=omacal
Icon=omacal
Categories=Office;Calendar;
Keywords=calendar;event;meeting;invitation;task;caldav;google;icloud;
Terminal=false
MimeType=text/calendar;
EOF
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR"
  fi
  xdg-mime default omacal.desktop text/calendar

  if command -v omarchy >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
    # Also support install.sh without first running chezmoi apply.
    mkdir -p "$CONFIG_DIR/omarchy/plugins/dotfiles.clock"
    for plugin_file in "$SCRIPT_DIR/../dot_config/omarchy/plugins/dotfiles.clock/"*; do
      destination="$CONFIG_DIR/omarchy/plugins/dotfiles.clock/$(basename "$plugin_file")"
      if ! cmp -s "$plugin_file" "$destination"; then
        install -m644 "$plugin_file" "$destination"
      fi
    done

    if omarchy-shell shell ping >/dev/null 2>&1; then
      # OmaCal unpacks its bundled widget on the first GUI start. Its own
      # one-time enable attempt can fail; explicitly reconcile enablement.
      if ! pgrep -u "$(id -u)" -x omacal >/dev/null; then
        uwsm-app -- "$BIN_DIR/omacal" --autostart >/dev/null 2>&1 &
      fi
      for (( attempt = 0; attempt < 50; attempt++ )); do
        [[ ! -f "$CONFIG_DIR/omarchy/plugins/omacal.upcoming/manifest.json" ]] || break
        sleep 0.2
      done
      omarchy-shell shell rescanPlugins
      omarchy plugin enable omacal.upcoming
      omarchy plugin enable dotfiles.clock
      # The agenda widget supplies the tray's calendar actions. Hide the
      # duplicate native tray item, preserving other hidden applications.
      # Some shell versions serialize array values through setBarWidget as
      # strings. Write the list as JSON and reload the user configuration.
      python3 "$SCRIPT_DIR/configure-omacal-bar.py" --tray-only
      omarchy-shell shell reloadConfig
    else
      # At bootstrap there may be no graphical shell yet. Queue the layout;
      # Hyprland autostart supplies the app and its widget on first login.
      python3 "$SCRIPT_DIR/configure-omacal-bar.py"
    fi
  fi
fi

echo "[INFO] OmaCal installed and selected as the default calendar"
