local fallback = "catppuccin"

-- Omarchy theme state only exists on Linux. Keep the shared macOS config on
-- its normal colorscheme instead of coupling it to an Omarchy path.
if (vim.uv or vim.loop).os_uname().sysname ~= "Linux" then
  return fallback
end

local theme_map = {
  ["catppuccin-latte"] = "catppuccin-latte",
  ["catppuccin"] = "catppuccin",
  ["everforest"] = "everforest",
  ["flexoki-light"] = "flexoki-light",
  ["gruvbox"] = "gruvbox",
  ["kanagawa"] = "kanagawa",
  ["matte-black"] = "matteblack",
  ["nord"] = "nordfox",
  ["osaka-jade"] = "bamboo",
  ["ristretto"] = "monokai-pro",
  ["rose-pine"] = "rose-pine-dawn",
  ["tokyo-night"] = "tokyonight-night",
}

local state_home = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
local f = io.open(state_home .. "/omarchy/current/theme.name", "r")
if f then
  local name = f:read("*l")
  f:close()
  return theme_map[name] or fallback
end
return fallback
