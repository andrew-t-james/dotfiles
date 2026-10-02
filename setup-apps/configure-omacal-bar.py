#!/usr/bin/env python3
"""Select OmaCal widgets or reconcile just the redundant tray icon."""

import json
import os
import sys
from pathlib import Path

config_home = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
shell_file = config_home / "omarchy/shell.json"
defaults_file = Path("/usr/share/omarchy/config/omarchy/shell.json")
config = json.loads((shell_file if shell_file.exists() else defaults_file).read_text())
tray_only = "--tray-only" in sys.argv[1:]
layout = config.setdefault("bar", {}).setdefault("layout", {})
clock_found = False
agenda_found = False
for section in ("left", "center", "right"):
    entries = layout.setdefault(section, [])
    for index, entry in enumerate(entries):
        widget_id = entry.get("id") if isinstance(entry, dict) else entry
        if not tray_only and widget_id in ("omarchy.clock", "dotfiles.clock"):
            entry = dict(entry) if isinstance(entry, dict) else {}
            entry["id"] = "dotfiles.clock"
            entries[index] = entry
            clock_found = True
        if widget_id == "omacal.upcoming":
            agenda_found = True
        if widget_id == "omarchy.tray":
            entry = dict(entry) if isinstance(entry, dict) else {"id": widget_id}
            hidden = entry.get("hidden", [])
            # Repair the string produced by older setBarWidget implementations.
            if isinstance(hidden, str):
                try:
                    hidden = json.loads(hidden)
                except json.JSONDecodeError:
                    hidden = [hidden]
            if isinstance(hidden, str):
                hidden = [hidden]
            if not isinstance(hidden, list):
                hidden = []
            entry["hidden"] = list(dict.fromkeys(
                hidden + ["tray-icon tray app omacal-tray"]
            ))
            entries[index] = entry
if not tray_only and not clock_found:
    layout["center"].append({"id": "dotfiles.clock"})
if not tray_only and not agenda_found:
    layout["right"].append({"id": "omacal.upcoming"})
if not tray_only:
    config["disabledPlugins"] = [
        plugin for plugin in config.get("disabledPlugins", [])
        if plugin not in ("dotfiles.clock", "omacal.upcoming")
    ]
    config["cloneSourceRestores"] = [
        plugin for plugin in config.get("cloneSourceRestores", [])
        if plugin != "omarchy.clock"
    ]
shell_file.parent.mkdir(parents=True, exist_ok=True)
shell_file.write_text(json.dumps(config, indent=2) + "\n")
