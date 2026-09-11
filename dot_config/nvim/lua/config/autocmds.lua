vim.filetype.add({
  extension = {
    templ = "templ",
  },
})

-- Reload the active Omarchy theme on Linux without changing macOS behavior.
local state_home = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
local omarchy_theme = state_home .. "/omarchy/current/theme.name"

if (vim.uv or vim.loop).os_uname().sysname == "Linux" and vim.fn.filereadable(omarchy_theme) == 1 then
  vim.api.nvim_create_autocmd("Signal", {
    pattern = "SIGUSR1",
    group = vim.api.nvim_create_augroup("omarchy_theme", {}),
    callback = function()
      package.loaded.theme = nil
      vim.cmd.colorscheme(require("theme"))
      vim.schedule(function()
        vim.cmd("redraw!")
      end)
    end,
    nested = true,
  })
end

-- don't add comment to new line if previous line is a comment
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  desc = "don't auto comment new line (command version)",
  pattern = "*",
  command = "setlocal formatoptions-=cro",
})
