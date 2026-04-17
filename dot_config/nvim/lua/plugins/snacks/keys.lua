return {
  {
    "<leader>un",
    function()
      Snacks.notifier.hide()
    end,
    desc = "Dismiss All Notifications",
  },
  {
    "<leader>bd",
    function()
      Snacks.bufdelete()
    end,
    desc = "Delete Buffer",
  },
  {
    "<leader>lg",
    function()
      Snacks.lazygit()
    end,
    desc = "Lazygit",
  },
  {
    "<leader>gb",
    function()
      Snacks.git.blame_line()
    end,
    desc = "Git Blame Line",
  },
  {
    "<leader>gB",
    function()
      Snacks.gitbrowse()
    end,
    desc = "Git Browse",
  },
  {
    "<leader>gf",
    function()
      Snacks.lazygit.log_file()
    end,
    desc = "Lazygit Current File History",
  },
  {
    "<leader>gl",
    function()
      Snacks.lazygit.log()
    end,
    desc = "Lazygit Log (cwd)",
  },
  {
    "<leader>cR",
    function()
      Snacks.rename()
    end,
    desc = "Rename File",
  },
  {
    "<c-/>",
    function()
      Snacks.terminal()
    end,
    desc = "Toggle Terminal",
  },
  {
    "<c-_>",
    function()
      Snacks.terminal()
    end,
    desc = "which_key_ignore",
  },
  {
    "]]",
    function()
      Snacks.words.jump(vim.v.count1)
    end,
    desc = "Next Reference",
    mode = { "n", "t" },
  },
  {
    "[[",
    function()
      Snacks.words.jump(-vim.v.count1)
    end,
    desc = "Prev Reference",
    mode = { "n", "t" },
  },
  {
    "<leader>N",
    desc = "Neovim News",
    function()
      Snacks.win({
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      })
    end,
  },
}
