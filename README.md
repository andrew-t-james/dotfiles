# Andrew's Dotfiles

Managed with [chezmoi](https://chezmoi.io). One command gets you from a fresh Mac to a fully configured machine.

## Quickstart

**Step 1 — Install Xcode CLT** (skip if already done):
```sh
xcode-select --install
```
Wait for the dialog to complete before continuing.

**Step 2 — Bootstrap:**
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/andrew-t-james/dotfiles/main/bootstrap.sh)"
```

**Step 3 — Open a new terminal, then authenticate GitHub CLI:**
```sh
gh auth login
```

**Step 4 — Re-apply to register SSH key with GitHub:**
```sh
chezmoi apply
```

The bootstrap will:
1. Install chezmoi and clone this repo to `~/dotfiles`
2. Prompt for your git email and whether this is a work machine
3. Install Xcode CLT + Homebrew + all packages from `Brewfile`
4. Install Rust via rustup
5. Apply all dotfiles to `~`
6. Set macOS defaults (dock, finder, keyboard repeat, trackpad)
7. Generate an SSH key (GitHub registration requires step 2 above)
8. Build the bat syntax/theme cache

## What gets installed

### GUI Apps (Homebrew Casks)
- **Terminals**: Ghostty (primary)
- **Editors**: Zed, Neovim (config included)
- **AI tools**: Claude, Claude Code, Codex, Copilot CLI
- **Productivity**: Raycast, Notion, OmaCal, Linear, Slack
- **Dev**: Beekeeper Studio, QMK Toolbox, Docker/OrbStack
- **Browsers**: Google Chrome, Chromium
- **Utilities**: CleanShot X, 1Password, AppCleaner, LocalSend

### CLI Tools (Homebrew Formulae)
- **Shell**: bat, btop, direnv, fzf, starship, tmux, zoxide
- **Git**: gh, git-delta, lazygit, lazydocker, git-lfs
- **Cloud**: awscli, aws-vault, cloudflared, stern
- **Languages**: mise (manages node/bun/python), go, zig, uv
- **Utilities**: jq, yq, ripgrep, fd, mkcert, pass, wget

### Dotfiles managed
| Config | Target |
|--------|--------|
| aerospace | `~/.config/aerospace/` |
| alacritty | `~/.config/alacritty/` |
| bat | `~/.config/bat/` |
| delta | `~/.config/delta/` |
| ghostty | `~/.config/ghostty/` |
| git | `~/.config/git/` |
| kitty | `~/.config/kitty/` |
| mise | `~/.config/mise/` |
| neofetch | `~/.config/neofetch/` |
| nvim | `~/.config/nvim/` |
| raycast-commands | `~/.config/raycast-commands/` |
| starship | `~/.config/starship.toml` |
| tmux | `~/.config/tmux/` |
| zsh | `~/.config/zsh/` |
| bash profile | `~/.bash_profile` (Linux only) |
| zprofile | `~/.zprofile` (Linux only) |
| bin | `~/.local/bin/` |
| hypr | `~/.config/hypr/` (Linux only) |

### Default calendar (macOS and Linux)

`chezmoi apply` installs [OmaCal](https://github.com/x3me/omacal) through its
upstream installer if missing and selects it as the default for `.ics` calendar
files. Prebuilt releases support Apple Silicon macOS and x86_64 Linux.
`bash install.sh --apply` also runs this setup on Omarchy.

- **Linux**: `Super+Shift+C` launches or focuses OmaCal on workspace **7**.
- **macOS**: `Cmd+Shift+C` launches or activates OmaCal on the **calendar** workspace.
- **Both**: `Alt+G` switches to the calendar workspace.

On Omarchy, the clock opens OmaCal's agenda popup, and the `omacal.upcoming`
widget shows your current or next meeting. `Super+Ctrl+Alt+D` toggles the same
agenda. Setup enables both widgets, and Hyprland starts OmaCal at login to keep
the bar's calendar feed available.
To hide the duplicate tray icon on Omarchy, turn off **OmaCal → Settings → Menu
bar → Show the tray icon**.

Sign in to your calendar accounts in OmaCal on each machine. Calendar data and
credentials stay local and are not stored in this repository. OmaCal provides
in-app updates; reapplying the dotfiles does not redownload an existing install.

## Post-install manual steps

1. **GPG keys** — restore from 1Password or USB backup, then set trust to ultimate
2. **SSH keys** — restore `id_ed25519` and `journey` from 1Password
3. **Password store** — `git clone git@github.com:andrew-t-james/pass-store.git ~/.password-store`
4. **Sign in** — 1Password, Claude, GitHub CLI (`gh auth login`)
5. **Rust tools** — `cargo install` any project-specific tools
6. **Go binaries** — `go install` goimports, gt, task, templ, etc.
7. **pipx tools** — `pipx install graphify vectorcode`
8. **Bun globals** — `bun install -g clawhub mcporter`

## Updating

```sh
chezmoi update
```

## Structure

```
dotfiles/
├── dot_config/          # chezmoi source → ~/.config/
├── dot_local/bin/       # chezmoi source → ~/.local/bin/
├── .chezmoi.toml.tmpl   # chezmoi config template (prompted on init)
├── .chezmoiignore       # excludes hypr on macOS, tmux plugins always
├── Brewfile             # all Homebrew packages
├── run_once_before_01-install-homebrew.sh.tmpl
├── run_once_before_02-install-rust.sh
├── run_once_after_01-macos-defaults.sh.tmpl
└── run_once_after_02-bat-theme.sh
```

The original stow directories (`aerospace/`, `nvim/`, etc.) are kept for reference.

## Linux desktop session restoration

Hyprland remembers the applications open in each user's session and reopens
them on the next login. Personal and work accounts keep separate snapshots in
`~/.local/state/desktop-session/apps.json`; there is no fixed app list.

The `desktop-session.service` user service captures changes every three seconds
and freezes the saved list when logind announces shutdown. Installed desktop
launchers handle native apps and Chromium web apps; regular Chromium windows
start with previous-session restoration before web apps. Applications without
a desktop launcher fall back to their executable when it can be identified.
Unidentified web apps and interpreter-hosted apps are logged rather than guessed.

This reopens applications, not exact window layouts, unsaved documents, or
terminal commands. Those depend on the application's own session features.

After `chezmoi apply`, Hyprland starts the tracker on the next login. To start
it in an existing session without reopening closed apps, seed it first:

```sh
desktop-session save
systemctl --user daemon-reload
systemctl --user enable --now desktop-session.service
```

Inspect the currently recognized apps with `desktop-session list`. Run the
regression checks with `PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s tests`.

`desktop-display-watch.service` checks only the active user's session. If an
enabled monitor reports zero width or height, it requests a Hyprland reload
to recover the display without closing apps. It skips inactive sessions,
failed IPC queries, and package transactions that pause monitor reloads.
Reload attempts are limited to one every 30 seconds if a display stays modeless.
