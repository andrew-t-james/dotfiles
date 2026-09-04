#!/usr/bin/env bash
set -euo pipefail

# Keep Omarchy's SDDM autologin on the primary account while giving both local
# accounts the same zsh login-shell setting. Their application data remains
# separate in each home directory.
primary_user="${2:-aj}"
shell_users=(aj aj-work)
apply=false
[[ ${1:-} == "--apply" ]] && apply=true

if ! $apply; then
  echo "[DRY RUN] Would configure SDDM autologin on tty1 for $primary_user"
  echo "[DRY RUN] Would set aj and aj-work login shells to /usr/bin/zsh"
  exit 0
fi

sudo install -Dm644 /dev/stdin /etc/sddm.conf.d/autologin.conf <<EOF
[Autologin]
User=$primary_user
Session=omarchy.desktop
EOF

for user in "${shell_users[@]}"; do
  getent passwd "$user" >/dev/null && sudo usermod --shell /usr/bin/zsh "$user"
done

echo "SDDM will autologin $primary_user on tty1; aj and aj-work now use zsh."
