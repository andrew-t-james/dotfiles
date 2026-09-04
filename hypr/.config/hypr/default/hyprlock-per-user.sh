#!/bin/bash

PIDFILE="$XDG_RUNTIME_DIR/hypridle.pid"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  kill "$(cat "$PIDFILE")"
  rm "$PIDFILE"
  notify-send "Stop locking computer when idle"
else
  uwsm app -- hypridle >/dev/null 2>&1 &
  echo $! >"$PIDFILE"
  notify-send "Now locking computer when idle"
fi
