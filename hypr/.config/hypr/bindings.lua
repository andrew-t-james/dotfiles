-- Personal bindings migrated from the pre-Quattro Hyprland .conf files.
-- Omarchy's defaults are loaded first; explicitly unbind keys we replace.

-- Use the left-hand home-row layout for workspaces instead of SUPER+1..0.
for code = 10, 19 do
  hl.unbind("SUPER + code:" .. code)
  hl.unbind("SUPER + SHIFT + code:" .. code)
end

local workspace_keys = {
  E = { 1, "Email" },
  S = { 2, "Social" },
  D = { 3, "Development" },
  F = { 4, "Browser" },
  W = { 5, "WhatsApp" },
  A = { 6, "AI" },
  G = { 7, "Calendar" },
}
for key, destination in pairs(workspace_keys) do
  local workspace, label = destination[1], destination[2]
  o.bind("ALT + " .. key, label, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("ALT + SHIFT + " .. key, "Move window to " .. label, hl.dsp.window.move({ workspace = tostring(workspace) }))
end

-- Replace Omarchy's default HEY Calendar shortcut with Google Calendar too.
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Google Calendar", {
  webapp = "https://calendar.google.com/calendar/u/0/r",
  focus = true,
})

-- Replace Omarchy's default HEY shortcut with Shortwave.
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Shortwave", {
  webapp = "https://app.shortwave.com",
  focus = true,
})

-- Replace Omarchy's default HEY compose shortcut with a Shortwave draft.
hl.unbind("SUPER + SHIFT + ALT + E")
o.bind("SUPER + SHIFT + ALT + E", "New Shortwave email", {
  webapp = "https://app.shortwave.com/mailto?uri=mailto%3A",
})

-- Restore the legacy Slack launcher on the current Chromium web app.
o.bind("SUPER + SHIFT + ALT + S", "Slack", {
  webapp = "https://app.slack.com/client/T0NBA084Q/D07AB2PJZH6",
  focus = true,
})

-- Vim-style focus and swapping.
for key, direction in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
  o.bind("ALT + " .. key, "Focus window " .. direction, hl.dsp.focus({ direction = direction }))
  o.bind("ALT + SHIFT + " .. key, "Swap window " .. direction, hl.dsp.window.swap({ direction = direction }))
end

-- Walker is no longer installed in Omarchy 4; keep the muscle memory and use
-- the stock apps menu.
o.bind("ALT + SPACE", "Apps menu", "omarchy-menu toggle apps")

-- Omarchy defaults SUPER+ALT+SPACE to the Apps menu. Keep it distinct from
-- ALT+SPACE by opening the root menu with system actions such as reboot.
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + ALT + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- macOS-style screenshot shortcuts retained from the old config.
o.bind("SUPER + SHIFT + 3", "Screenshot window", "omarchy-capture-screenshot windows")
o.bind("SUPER + SHIFT + 4", "Screenshot region", "omarchy-capture-screenshot region")
