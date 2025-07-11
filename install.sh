#!/usr/bin/env bash
set -euo pipefail

# -------------------- Config --------------------
REPO_URL="git@github.com:andrew-t-james/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Packages to install via package manager
COMMON_PACKAGES=(bat tmux sesh zsh stow starship)

# Dotfiles directories to stow
STOW_PACKAGES=(bat tmux hypr sesh zsh starship nvim)

OS="$(uname -s)"
INSTALL_MODE=false

# -------------------- Argument Parsing --------------------
if [[ ${1:-} == "--apply" ]]; then
  INSTALL_MODE=true
  echo "[INFO] Running in APPLY mode"
else
  echo "[INFO] Running in DRY RUN mode"
  echo "[INFO] Add --apply to perform installation."
fi

# -------------------- OS Detection & Package Manager Setup --------------------
if [[ "$OS" == "Linux" ]]; then
  PKG_MANAGER="pacman"
  INSTALL_CMD="sudo pacman -Syu --noconfirm"
elif [[ "$OS" == "Darwin" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "[INFO] Homebrew not found."

    if $INSTALL_MODE; then
      echo "[INFO] Installing Homebrew..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add Homebrew to PATH
      eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >>~/.zprofile
    else
      echo "[DRY RUN] Would install Homebrew"
    fi
  else
    echo "[INFO] Homebrew is already installed."
  fi

  PKG_MANAGER="brew"
  INSTALL_CMD="brew install"
else
  echo "[ERROR] Unsupported OS: $OS"
  exit 1
fi

# -------------------- Package Installation --------------------
echo
echo "[INFO] Packages to install with $PKG_MANAGER:"
printf ' - %s\n' "${COMMON_PACKAGES[@]}"

if $INSTALL_MODE; then
  echo "[INFO] Installing packages..."
  for pkg in "${COMMON_PACKAGES[@]}"; do
    echo "[INFO] Installing $pkg..."
    $INSTALL_CMD "$pkg"
  done
else
  echo "[DRY RUN] Skipping package installation"
fi

# -------------------- Dotfiles Repository Clone --------------------
echo
echo "[INFO] Dotfiles will be cloned to $DOTFILES_DIR"
echo "[INFO] Git remote set to: $REPO_URL"

if $INSTALL_MODE; then
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    echo "[INFO] Dotfiles already cloned, skipping clone"
  else
    echo "[INFO] Cloning dotfiles..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
  fi
else
  echo "[DRY RUN] Skipping git clone"
fi

# -------------------- ZSH Setup --------------------
echo
echo "[INFO] Running setup-zsh.sh from dotfiles"

if $INSTALL_MODE; then
  bash "$DOTFILES_DIR/setup-zsh.sh"
else
  echo "[DRY RUN] Would run: bash $DOTFILES_DIR/setup-zsh.sh"
fi

# -------------------- Bat Theme Setup --------------------
echo
echo "[INFO] Setting up Catppuccin bat theme"

if $INSTALL_MODE; then
  bash "$DOTFILES_DIR/setup-bat.sh"
else
  echo "[DRY RUN] Would run: bash $DOTFILES_DIR/setup-bat.sh"
fi

# -------------------- Oh My Zsh Installation --------------------
echo
echo "[INFO] Installing oh-my-zsh"

if $INSTALL_MODE; then
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "[DRY RUN] Would run oh-my-zsh install script"
fi

# -------------------- Dotfiles Stow --------------------
echo
echo "[INFO] Stowing dotfiles packages:"
printf ' - %s\n' "${STOW_PACKAGES[@]}"

cd "$DOTFILES_DIR"

for pkg in "${STOW_PACKAGES[@]}"; do
  if $INSTALL_MODE; then
    echo "[INFO] Stowing $pkg..."
    stow "$pkg"
  else
    echo "[DRY RUN] Would run: stow $pkg"
  fi
done

echo
echo "[INFO] Setup complete!"
