vim.filetype.add({
  extension = {
    templ = "templ",
  },
})

-- don't add comment to new line if previous line is a comment
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  desc = "don't auto comment new line (command version)",
  pattern = "*",
  command = "setlocal formatoptions-=cro",
})
