vim.filetype.add({
  extension = {
    templ = "templ",
  },
})

-- Omarchy theme integration via SIGUSR1
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

-- don't add comment to new line if previous line is a comment
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  desc = "don't auto comment new line (command version)",
  pattern = "*",
  command = "setlocal formatoptions-=cro",
})
