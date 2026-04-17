# ====================
# AWS Tools
# ====================

# agnc dotenvx keys
if command -v pass >/dev/null 2>&1 && [ -z "${DOTENV_PRIVATE_KEY:-}" ]; then
  _ag_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  _ag_cache_file="$_ag_cache_dir/agnc-dotenv-private-key.env"
  _ag_cache_ttl="${AGN_DOTENV_CACHE_TTL_SECONDS:-43200}"

  mkdir -p "$_ag_cache_dir"

  _ag_refresh_cache=1
  if [ -f "$_ag_cache_file" ]; then
    _ag_now="$(date +%s)"
    _ag_mtime="$(stat -f %m "$_ag_cache_file" 2>/dev/null || printf '0')"
    if [ $((_ag_now - _ag_mtime)) -lt "$_ag_cache_ttl" ]; then
      _ag_refresh_cache=0
    fi
    unset _ag_now _ag_mtime
  fi

  if [ "$_ag_refresh_cache" -eq 1 ]; then
    _ag_key_line="$(pass show agnc/env 2>/dev/null | command grep '^DOTENV_PRIVATE_KEY=' | head -n 1)"
    if [ -n "$_ag_key_line" ]; then
      umask 077
      printf 'export %s\n' "$_ag_key_line" >"$_ag_cache_file"
    fi
    unset _ag_key_line
  fi

  if [ -f "$_ag_cache_file" ]; then
    source "$_ag_cache_file"
  fi

  unset _ag_cache_dir _ag_cache_file _ag_cache_ttl _ag_refresh_cache
fi
