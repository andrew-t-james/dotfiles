# KMonad + Miryoku Setup for macOS

This directory contains a complete setup for KMonad with the Miryoku ergonomic keyboard layout on macOS, including pre-built configurations and build tools.

## What is This?

- **KMonad**: A keyboard remapping tool that works at the system level
- **Miryoku**: An ergonomic, minimal, orthogonal keyboard layout with home row modifiers and layer-based functionality
- **Flipped Configuration**: Number/Symbol/Function layers are flipped from their default positions for better ergonomics

## Prerequisites

- macOS 10.12+ (tested on macOS 15.0)
- Homebrew package manager
- Administrator access (for installing system extensions)

## Quick Start (Using Pre-built Configurations)

If you just want to use the pre-built configurations:

1. [Install KMonad](#install-kmonad) (steps 1-5 below)
2. Use one of the ready-made configurations:
   - `miryoku_qwerty_flipped.kbd` - QWERTY with flipped layers (recommended)
   - `miryoku_flipped.kbd` - Colemak-DH with flipped layers
   - `apple.kbd` - Simple Apple keyboard template
3. [Run KMonad](#usage) with your chosen configuration

## Step-by-Step Installation

### 1. Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Navigate to Configuration Directory

```bash
# If using dotfiles repo
cd ~/dotfiles/keyboard/kmonad

# Or if you cloned this separately
cd path/to/kmonad-setup
```

### 3. Install Required Tools

```bash
# Install Haskell Stack
brew install haskell-stack
```

### 4. Install KMonad

Download and install the latest KMonad release from GitHub, or compile from source:

```bash
# Option 1: Download pre-compiled binary (recommended)
# Visit https://github.com/kmonad/kmonad/releases and download the macOS binary

# Option 2: Compile from source
git clone --recursive https://github.com/kmonad/kmonad.git temp_kmonad
cd temp_kmonad
stack install --flag kmonad:dext
cd .. && rm -rf temp_kmonad
```

### 5. Install Virtual HID Device Driver

Download and install the Karabiner VirtualHIDDevice:

```bash
# Download the installer
curl -L -o karabiner-virtualhiddevice.pkg \
  "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/latest/download/Karabiner-DriverKit-VirtualHIDDevice-5.0.0.pkg"

# Install it
open karabiner-virtualhiddevice.pkg
```

Follow the installer prompts, then activate the device:

```bash
/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate
```

**Note**: This command may appear to hang - this is normal. You can interrupt it after a few seconds.

## Custom Configuration Generation

To generate your own custom configurations:

```bash
# QWERTY with flipped layers (recommended)
make MIRYOKU_LAYERS=FLIP MIRYOKU_KMONAD_OS=MAC MIRYOKU_ALPHAS=QWERTY

# The generated configuration will be in build/miryoku_kmonad.kbd
```

## System Permissions

1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Select **Input Monitoring** from the left sidebar
3. Click the lock and enter your password
4. Add Terminal (or your terminal app) to the list
5. You may also need to add `kmonad` itself when you first run it

## Usage

### Testing the Configuration (Dry Run)

```bash
# Test without actually applying changes (use any .kbd file)
kmonad -d miryoku_qwerty_flipped.kbd
```

### Running KMonad

```bash
# Apply the configuration (requires sudo)
sudo kmonad miryoku_qwerty_flipped.kbd
```

**Important**: You'll need to specify your actual keyboard device. Edit the configuration file and replace `MIRYOKU_KMONAD_KEYBOARD_MAC` with your keyboard identifier.

To find your keyboard:

```bash
# List available input devices
ls /dev/input/
```

## Configuration Options

### Alternative Layouts

```bash
# Colemak-DH (default)
make MIRYOKU_LAYERS=FLIP MIRYOKU_KMONAD_OS=MAC

# QWERTY
make MIRYOKU_LAYERS=FLIP MIRYOKU_KMONAD_OS=MAC MIRYOKU_ALPHAS=QWERTY

# Dvorak
make MIRYOKU_LAYERS=FLIP MIRYOKU_KMONAD_OS=MAC MIRYOKU_ALPHAS=DVORAK
```

### Layer Options

```bash
# Standard layers
make MIRYOKU_KMONAD_OS=MAC MIRYOKU_ALPHAS=QWERTY

# Flipped layers (recommended for right-handed users)
make MIRYOKU_LAYERS=FLIP MIRYOKU_KMONAD_OS=MAC MIRYOKU_ALPHAS=QWERTY
```

### Mapping Options

```bash
# Default angled ortho split mapping
make MIRYOKU_LAYERS=FLIP MIRYOKU_KMONAD_OS=MAC MIRYOKU_ALPHAS=QWERTY

# Lite mapping (preserves traditional home positions)
make MIRYOKU_LAYERS=FLIP MIRYOKU_KMONAD_OS=MAC MIRYOKU_ALPHAS=QWERTY MIRYOKU_MAPPING=LITE
```

## Layout Overview

### Base Layer (QWERTY)
```
q  w  e  r  t    y  u  i  o  p
a  s  d  f  g    h  j  k  l  '
z  x  c  v  b    n  m  ,  .  /
      del bspc ent    tab spc esc
```

### Home Row Modifiers
- **Left hand**: A(Meta) S(Alt) D(Ctrl) F(Shift)
- **Right hand**: J(Shift) K(Ctrl) L(Alt) ;(Meta)

### Thumb Keys (Layer Access)
- **Left thumb**: Del(Fun) Backspace(Num) Enter(Sym)
- **Right thumb**: Tab(Mouse) Space(Nav) Esc(Media)

### Flipped Layers
When `MIRYOKU_LAYERS=FLIP` is used:
- Numbers are on the right thumb instead of left
- Symbols are on the left thumb instead of right
- Function keys are on the left thumb instead of right

## Troubleshooting

### KMonad Not Found
Add the installation directory to your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Permission Denied
- Ensure you're running with `sudo`
- Check Input Monitoring permissions in System Preferences
- Try running Terminal with administrator privileges

### Compilation Errors
- Ensure you have the latest Xcode command line tools: `xcode-select --install`
- Try updating Stack: `stack upgrade`

### Virtual HID Device Issues
- Restart your computer after installing the driver
- Check that the VirtualHIDDevice Manager shows the device as active
- Try reinstalling the Karabiner VirtualHIDDevice package

## Files in This Directory

### Ready-to-use Configurations
- `miryoku_qwerty_flipped.kbd`: Pre-built QWERTY with flipped layers (recommended)
- `miryoku_flipped.kbd`: Pre-built Colemak-DH with flipped layers
- `apple.kbd`: Simple Apple keyboard example
- `tutorial.kbd`: Comprehensive KMonad tutorial with examples

### Build System
- `makefile`: Build configuration files
- `miryoku_kmonad.kbd.cpp`: Main Miryoku source template
- `miryoku.h`: Miryoku layout definitions
- `miryoku_babel/`: Layer and layout data
- `post_rules.mk`, `custom_config.h`, `custom_rules.mk`: Build configuration
- `build/`: Generated configurations directory

## References

- [KMonad Documentation](https://github.com/kmonad/kmonad)
- [Miryoku Layout](https://github.com/manna-harbour/miryoku)
- [Miryoku KMonad Implementation](https://github.com/manna-harbour/miryoku_kmonad)
- [KMonad Installation Guide](https://github.com/kmonad/kmonad/blob/master/doc/installation.md)

## Security Note

KMonad requires system-level access to intercept and modify keyboard input. Only use configurations from trusted sources and review them before use. The configurations in this repository implement the well-documented Miryoku layout without any malicious functionality.