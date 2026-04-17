-- Disable LazyVim's built-in fzf-lua so fff owns all picker keybindings
local disable_fzf = { "ibhagwan/fzf-lua", enabled = false }

local fff = {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  opts = {
    debug = {
      enabled = false,
      show_scores = false,
    },
    layout = {
      height = 0.8,
      width = 0.8,
      preview_position = "right",
      preview_size = 0.5,
    },
    grep = {
      smart_case = true,
      modes = { "plain", "regex", "fuzzy" },
    },
    frecency = {
      enabled = true,
    },
  },
  keys = {
    { "<leader><space>", function() require("fff").find_files() end, desc = "Find Files (Root Dir)" },
    { "<leader>ff", function() require("fff").find_files() end, desc = "Find Files (Root Dir)" },
    { "<leader>fF", function() require("fff").find_files_in_dir(vim.uv.cwd()) end, desc = "Find Files (cwd)" },
    { "<leader>/", function() require("fff").live_grep() end, desc = "Grep (Root Dir)" },
    { "<leader>sg", function() require("fff").live_grep() end, desc = "Grep (Root Dir)" },
    { "<leader>sG", function() require("fff").live_grep() end, desc = "Grep (cwd)" },
    { "<leader>sw", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, desc = "Word (Root Dir)" },
    { "<leader>sw", function() require("fff").live_grep({ query = vim.fn.expand("<cword>") }) end, mode = "v", desc = "Selection (Root Dir)" },
    {
      "ff",
      function() require("fff").find_files() end,
      desc = "FFFind files",
    },
    {
      "fg",
      function() require("fff").live_grep() end,
      desc = "Live grep",
    },
    {
      "fz",
      function() require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } }) end,
      desc = "Live fuzzy grep",
    },
  },
}

return { disable_fzf, fff }
