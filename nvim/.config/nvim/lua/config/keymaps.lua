-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Write File" })

-- center text on jump
keymap("", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- keep cursor in place while moving
keymap("", "J", "mzJ`z", opts)

-- toggle relative line numbers
keymap("n", "<leader>z", ":lua ToggleRelativeLineNumbers()<CR>", opts)

-- make Y behave like D || C
keymap("n", "Y", "y$", opts)

-- center 🌏 all the things
keymap("n", "<c-m>", "<s-m>", opts)
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)
keymap("n", "<C-i>", "<C-i>zz", opts)
keymap("n", "<C-o>", "<C-o>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "#", "#zz", opts)
keymap("n", "%", "%zz", opts)
keymap("n", "{", "{zz", opts)
keymap("n", "}", "}zz", opts)

-- search word under cursor
-- vim.keymap.set("n", "tt",
--   ":lua require('telescope.builtin').grep_string({ search = vim.fn.expand('<cword>'), initial_mode = 'normal' })<CR>",
--   opts)

vim.keymap.set("n", "tt", function()
  require("fzf-lua").grep_cword()
end, opts)

-- nvim tmux navigation keymaps
keymap("n", "<C-h>", require("nvim-tmux-navigation").NvimTmuxNavigateLeft)
keymap("n", "<C-j>", require("nvim-tmux-navigation").NvimTmuxNavigateDown)
keymap("n", "<C-k>", require("nvim-tmux-navigation").NvimTmuxNavigateUp)
keymap("n", "<C-l>", require("nvim-tmux-navigation").NvimTmuxNavigateRight)
keymap("n", "<C-\\>", require("nvim-tmux-navigation").NvimTmuxNavigateLastActive)

-- open in gh
keymap("n", "<Leader>gr", ":OpenInGHRepo <CR>", opts)
-- for current file page
keymap("n", "<Leader>gy", ":OpenInGHFile <CR>", opts)
keymap("v", "<Leader>gy", ":OpenInGHFileLines <CR>", opts)

-- Move current line down in normal mode
keymap("n", "<S-C-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
-- Move current line up in normal mode
keymap("n", "<S-C-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
-- Move current line down in insert mode
keymap("i", "<S-C-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
-- Move current line up in insert mode
keymap("i", "<S-C-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
-- Move selected lines down in visual mode
keymap("v", "<S-C-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
-- Move selected lines up in visual mode
keymap("v", "<S-C-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

-- jump to definition in splits
keymap("n", "gv", function()
  vim.cmd("vsplit")
  vim.lsp.buf.definition()
end, { desc = "Go to definition in vertical split" })
keymap("n", "gs", "<C-W><C-]>", { desc = "Split and go to tag definition" })
