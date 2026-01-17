# ---------------- ZSH OPTIONS ----------------
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

HISTSIZE=32768
SAVEHIST=32768
HISTFILE="$HOME/.zsh_history"

# ---------------- LOCAL SCRIPTS ----------------

ZSH_LOCAL="$HOME/.config/zsh"

[[ -f "$ZSH_LOCAL/alias.sh" ]] && source "$ZSH_LOCAL/alias.sh"
[[ -f "$ZSH_LOCAL/functions.sh" ]] && source "$ZSH_LOCAL/functions.sh"
[[ -f "$ZSH_LOCAL/clone-worktree.sh" ]] && source "$ZSH_LOCAL/clone-worktree.sh"

bindkey -v  # Optional: enable vi-mode keybindings

# ---------------- PATH SETUP ----------------
typeset -U path
path=(
  ./bin
  $HOME/.local/bin
  $HOME/.local/share/omarchy/bin
  $path
)
export PATH

# ---------------- ANTIGEN SETUP ----------------
ANTIGEN_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/antigen.zsh"
[[ -f "$ANTIGEN_PATH" ]] && source "$ANTIGEN_PATH"

antigen use oh-my-zsh

# Core plugins
antigen bundle git
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

# Apply plugins
antigen apply

# ---------------- STARSHIP ----------------
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# ---------------- TOOL INIT ----------------
# mise (environment/version manager)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# zoxide (smarter cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf keybindings
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi

# macOS Homebrew fzf path fallback
if [[ "$OSTYPE" == "darwin"* && -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

# ---------------- DIRENV ----------------
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# ---------------- FUNCTIONS ----------------

compress() {
  tar -czf "$1.tar.gz" "$1"
}

zd() {
  if [[ $# -eq 0 ]]; then
    cd ~
  elif [[ -d "$1" ]]; then
    cd "$1"
  else
    z "$@" && printf " \U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

open() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$@"  # macOS native
  else
    xdg-open "$@" >/dev/null 2>&1
  fi
}

iso2sd() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/ubuntu.iso /dev/sda"
    echo -e "\nAvailable SD cards:"
    lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
    return 1
  fi
  sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
  sudo eject "$2"
}

web2app() {
  if [[ $# -ne 3 ]]; then
    echo "Usage: web2app <AppName> <AppURL> <IconURL>"
    return 1
  fi

  local APP_NAME="$1"
  local APP_URL="$2"
  local ICON_URL="$3"
  local ICON_DIR="$HOME/.local/share/applications/icons"
  local DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
  local ICON_PATH="$ICON_DIR/$APP_NAME.png"

  mkdir -p "$ICON_DIR"

  if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
    echo "Error: Failed to download icon."
    return 1
  fi

  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=zen-browser --new-instance -P $APP_NAME --name $APP_NAME --new-window $APP_URL
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

  chmod +x "$DESKTOP_FILE"
}

web2app-remove() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: web2app-remove <AppName>"
    return 1
  fi

  local APP_NAME="$1"
  local ICON_DIR="$HOME/.local/share/applications/icons"
  local DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
  local ICON_PATH="$ICON_DIR/$APP_NAME.png"

  rm -f "$DESKTOP_FILE" "$ICON_PATH"
}

refresh-xcompose() {
  pkill fcitx5
  setsid fcitx5 &>/dev/null &
}
