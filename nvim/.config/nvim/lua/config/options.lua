-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.g.vscode = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false

vim.cmd("syntax on") -- syntax highlighting
vim.cmd("set iskeyword+=-") -- treat dash separated words as a word text object"
vim.cmd("set shortmess+=c") -- Don't pass messages to |ins-completion-menu|.
vim.cmd("set inccommand=split") -- Make substitution work in real-time
vim.cmd("set spell")
vim.cmd("set spelllang=en,cjk")
vim.cmd("set spellsuggest=best,9")
-- vim.cmd(
-- 'hi SpellBad guisp=red gui=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE term=underline cterm=undercurl ctermul=red')
vim.o.title = true
-- TERMINAL = vim.fn.expand('$TERMINAL')
-- vim.cmd('let &titleold="' .. TERMINAL .. '"')
vim.o.titlestring = "%<%F%=%l/%L - nvim"
-- vim.cmd('set spell spelllang=en_us')

vim.o.showtabline = 2 -- Always show buffer tabs
vim.o.hidden = true -- Allow multiple buffers to be open
-- vim.wo.wrap = WrapLine -- Don't wrap line
-- vim.wo.number = LineNumbers
-- vim.wo.relativenumber = RelativeLineNumbers
-- vim.o.cursorline = CursorLine -- Highlight current line
vim.o.splitbelow = true -- Hsplit below
vim.o.splitright = true -- Vsplit to the right

vim.o.termguicolors = true
vim.o.background = "dark"
vim.cmd('let &t_8f = "\\<Esc>[38;2;%lu;%lu;%lum"')
vim.cmd('let &t_8b = "\\<Esc>[48;2;%lu;%lu;%lum"')

-- vim.cmd('set colorcolumn=' .. ColorColumn)
-- vim.o.hlsearch = HighlightSearch -- Don't highlight search matches
-- vim.o.ignorecase = SearchIgnoreCase -- Default case insensitive search
vim.o.smartcase = true -- Case sensitive if search has a capital letter

-- Use undofile instead of swap files for history
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir/"
vim.o.undofile = true

-- vim.cmd('set ts=' .. TabSize)
-- vim.cmd('set sw=' .. TabSize)
-- vim.o.expandtab = UseSpaces -- Convert tabs to spaces
vim.o.smartindent = true -- Makes indenting smart
vim.o.autoindent = true -- Auto indent

vim.o.fileencoding = "utf-8" -- File encoding
vim.o.pumheight = 10 -- Popup menu height
vim.o.cmdheight = 1 -- Space for cmd messages
vim.o.laststatus = 2 -- Always display the status line
vim.o.conceallevel = 0 -- Show `` in markdown files
vim.o.showmode = false -- Hide the editing mode
vim.o.writebackup = false -- This is recommended by coc
vim.o.updatetime = 300 -- Faster completion
vim.o.timeoutlen = 500 -- By default timeoutlen is 1000 ms
vim.o.clipboard = "unnamedplus" -- Copy paste between vim and everything else
vim.wo.signcolumn = "yes"

function ToggleRelativeLineNumbers()
  -- Get current buffer and window
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  -- Initialize buffer-local storage if it doesn't exist
  if not vim.b[bufnr].line_nr_hl then
    vim.b[bufnr].line_nr_hl = vim.api.nvim_get_hl(0, { name = "LineNr" })
  end

  -- Create a unique highlight group name for this buffer
  local hl_group = "LineNr_" .. bufnr

  if vim.wo[win].relativenumber == true then
    vim.wo[win].relativenumber = false
    -- Set to lavender when relative numbers are off
    local colors = require("catppuccin.palettes").get_palette()
    -- Create buffer-specific highlight group
    vim.api.nvim_set_hl(0, hl_group, { fg = colors.lavender, bold = true })
    -- Set the window's line number highlight group
    vim.wo[win].winhl = "LineNr:" .. hl_group
  else
    vim.wo[win].relativenumber = true
    -- Restore original highlighting for this buffer
    vim.api.nvim_set_hl(0, hl_group, vim.b[bufnr].line_nr_hl)
    -- Reset the window's line number highlight group
    vim.wo[win].winhl = "LineNr:" .. hl_group
  end
end

-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
