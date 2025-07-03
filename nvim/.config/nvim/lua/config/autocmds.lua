-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- don't add comment to new line if previous line is a comment
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  desc = "don't auto comment new line (command version)",
  pattern = "*",
  command = "setlocal formatoptions-=cro",
})
