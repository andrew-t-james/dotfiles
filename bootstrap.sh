#!/usr/bin/env bash
set -euo pipefail

# ---------------- CONFIG ----------------
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
STOW_DIRS=("zsh" "starship")
OHMYZSH_DIR="$HOME/.oh-my-zsh"
ANTIGEN_PATH="$HOME/.config/antigen.zsh"
ZSHRC_PATH="$HOME/.zshrc"

# ---------------- HELPER ----------------
info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }

ok() { echo -e "\033[1;32m[ OK ]\033[0m $*"; }

error() {
  echo -e "\033[1;31m[ERR ]\033[0m $*" >&2
  exit 1
}

# ---------------- INSTALL ZSH ----------------
if ! command -v zsh &>/dev/null; then
  info "Installing Zsh..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zsh
  elif command -v yay &>/dev/null; then
    yay -S --noconfirm zsh
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm zsh
  else
    error "Unsupported system: install Zsh manually"
  fi
  ok "Zsh installed"
else
  info "Zsh already installed"
fi

# ---------------- STOW CONFIG FILES ----------------
info "Stowing dotfiles: ${STOW_DIRS[*]}"
cd "$DOTFILES_DIR"
for dir in "${STOW_DIRS[@]}"; do
  stow "$dir"
done
ok "Dotfiles stowed"

# ---------------- OH-MY-ZSH ----------------
if [[ ! -d "$OHMYZSH_DIR" ]]; then
  info "Installing Oh My Zsh silently..."
  export RUNZSH=no
  export CHSH=no
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
  ok "Oh My Zsh installed"
else
  info "Oh My Zsh already installed"
fi

# ---------------- ANTIGEN ----------------
if [[ ! -f "$ANTIGEN_PATH" ]]; then
  info "Installing Antigen..."
  curl -L git.io/antigen >"$ANTIGEN_PATH"
  ok "Antigen installed"
else
  info "Antigen already installed"
fi

# ---------------- STARSHIP ----------------
if ! command -v starship &>/dev/null; then
  info "Installing Starship..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install starship
  elif command -v yay &>/dev/null; then
    yay -S --noconfirm starship
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm starship
  else
    error "Unsupported system: install Starship manually"
  fi
  ok "Starship installed"
else
  info "Starship already installed"
fi

# ---------------- ~/.zshrc BRIDGE ----------------
if [[ ! -f "$ZSHRC_PATH" || "$(cat "$ZSHRC_PATH")" != "source ~/.config/zsh/.zshrc" ]]; then
  info "Linking ~/.zshrc to ~/.config/zsh/.zshrc"
  echo 'source ~/.config/zsh/.zshrc' >"$ZSHRC_PATH"
  ok "~/.zshrc linked"
else
  info "~/.zshrc already linked"
fi

# ---------------- Set Zsh as Default Shell ----------------
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  info "Setting Zsh as default shell for user $USER"
  chsh -s "$(command -v zsh)"
  ok "Default shell changed to Zsh"
else
  info "Zsh already set as default shell"
fi

# ---------------- DONE ----------------
ok "Bootstrap complete. Launching Zsh..."
exec zsh
