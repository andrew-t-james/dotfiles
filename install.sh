#!/usr/bin/env bash
set -euo pipefail

# -------------------- Config --------------------
REPO_URL="https://github.com/andrew-t-james/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Packages to install via package manager
COMMON_PACKAGES=(bat tmux sesh zsh stow starship direnv)

# Dotfiles directories to stow
STOW_PACKAGES=(bat tmux hypr zsh starship nvim)

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
  # Ensure yay is installed
  if ! command -v yay >/dev/null 2>&1; then
    echo "[INFO] yay not found."

    if $INSTALL_MODE; then
      echo "[INFO] Installing yay from AUR..."
      sudo pacman -S --noconfirm git base-devel
      git clone https://aur.archlinux.org/yay.git /tmp/yay
      pushd /tmp/yay >/dev/null
      makepkg -si --noconfirm
      popd >/dev/null
      rm -rf /tmp/yay
    else
      echo "[DRY RUN] Would install yay from AUR"
    fi
  else
    echo "[INFO] yay is already installed."
  fi

  PKG_MANAGER="yay"
  INSTALL_CMD="yay -S --noconfirm"

elif [[ "$OS" == "Darwin" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "[INFO] Homebrew not found."

    if $INSTALL_MODE; then
      echo "[INFO] Installing Homebrew..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add Homebrew to PATH
      if [[ -d "/opt/homebrew/bin" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >>~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
      fi
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
  echo "[DRY RUN] Would install packages:"
  printf ' - %s\n' "${COMMON_PACKAGES[@]}"
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
  echo "[DRY RUN] Would clone repo to $DOTFILES_DIR"
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

# -------------------- Optional Reboot --------------------
if $INSTALL_MODE; then
  echo
  read -rp "Do you want to reboot now? [y/N]: " REBOOT_CONFIRM
  case "$REBOOT_CONFIRM" in
  [yY][eE][sS] | [yY])
    echo "[INFO] Rebooting..."
    reboot
    ;;
  *)
    echo "[INFO] Reboot skipped."
    ;;
  esac
else
  echo "[DRY RUN] Would prompt for reboot."
fi
