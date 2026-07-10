local function load_herdr_navigation()
  if vim.fn.executable("herdr") == 0 then
    return false
  end

  local output = vim.fn.system({ "herdr", "plugin", "list", "--json" })
  if vim.v.shell_error ~= 0 then
    return false
  end

  local ok, response = pcall(vim.json.decode, output)
  if not ok or type(response) ~= "table" or type(response.result) ~= "table" then
    return false
  end

  for _, plugin in ipairs(response.result.plugins or {}) do
    if
      plugin.plugin_id == "vim-herdr-navigation"
      and plugin.enabled ~= false
      and type(plugin.plugin_root) == "string"
    then
      local integration = plugin.plugin_root .. "/editor/nvim.lua"
      if vim.fn.filereadable(integration) == 1 then
        return pcall(dofile, integration)
      end
      return false
    end
  end

  return false
end

local function load_tmux_navigation_fallback()
  local ok, navigation = pcall(require, "nvim-tmux-navigation")
  if not ok then
    return
  end

  local options = { silent = true }
  vim.keymap.set("n", "<C-h>", navigation.NvimTmuxNavigateLeft, options)
  vim.keymap.set("n", "<C-j>", navigation.NvimTmuxNavigateDown, options)
  vim.keymap.set("n", "<C-k>", navigation.NvimTmuxNavigateUp, options)
  vim.keymap.set("n", "<C-l>", navigation.NvimTmuxNavigateRight, options)
end

if not load_herdr_navigation() then
  load_tmux_navigation_fallback()
end
