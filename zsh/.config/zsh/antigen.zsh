# -------------------- Install Antigen --------------------
ANTIGEN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
ANTIGEN_FILE="$ANTIGEN_DIR/antigen.zsh"

if [[ -f "$ANTIGEN_FILE" ]]; then
    echo "[INFO] Antigen already installed at $ANTIGEN_FILE"
else
    echo "[INFO] Installing Antigen to $ANTIGEN_FILE"
    mkdir -p "$ANTIGEN_DIR"
    curl -L git.io/antigen > "$ANTIGEN_FILE"
fi

