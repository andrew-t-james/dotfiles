-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config. Ignore a
-- pre-Quattro OMARCHY_PATH if an old UWSM environment leaked into the session.
local omarchy_path = os.getenv("OMARCHY_PATH") or "/usr/share/omarchy"
local bootstrap = omarchy_path .. "/default/hypr/bootstrap.lua"
local bootstrap_file = io.open(bootstrap, "r")
if bootstrap_file then
  bootstrap_file:close()
else
  omarchy_path = "/usr/share/omarchy"
  bootstrap = omarchy_path .. "/default/hypr/bootstrap.lua"
end
dofile(bootstrap)
package.path = omarchy_path .. "/?.lua;" .. package.path
package.loaded["default.hypr.paths"] = {
  home = os.getenv("HOME"),
  config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"),
  state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state"),
  omarchy_path = omarchy_path,
}

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Each Linux user has an independent Chromium profile and Slack launcher, but
-- every Slack web-app window belongs on the Social workspace.
o.window("(?i).*slack.*", { workspace = "2" })

-- Keep Shortwave mail on the Email workspace.
o.window("^chrome-app\\.shortwave\\.com__.*$", { workspace = "1" })

-- Keep the native ChatGPT app on the AI workspace (ALT+A).
o.window("(?i)^chatgpt$", { workspace = "6" })
