-- Returns colorscheme based on omarchy theme
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

local f = io.open(vim.fn.expand("~/.config/omarchy/current/theme.name"), "r")
if f then
  local name = f:read("*l")
  f:close()
  return theme_map[name] or "default"
end
return "default"
