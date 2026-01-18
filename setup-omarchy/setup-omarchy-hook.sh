#!/usr/bin/env bash
# Sets up omarchy theme-set hook for live nvim theme reloading

HOOK_DIR="$HOME/.config/omarchy/hooks"
HOOK_FILE="$HOOK_DIR/theme-set"

APPLY=false
[[ ${1:-} == "--apply" ]] && APPLY=true

if $APPLY; then
  mkdir -p "$HOOK_DIR"

  cat > "$HOOK_FILE" << 'EOF'
#!/usr/bin/env bash
kill -s SIGUSR1 $(pidof nvim) 2>/dev/null
EOF

  chmod +x "$HOOK_FILE"
  echo "[INFO] Created $HOOK_FILE"
else
  echo "[DRY RUN] Would create $HOOK_FILE"
fi
