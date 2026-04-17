return {
  "dmmulroy/tsc.nvim",
  config = function()
    require("tsc").setup({
      use_trouble_qflist = true,
      auto_open_qflist = false,
      auto_close_qflist = false,
      auto_focus_qflist = false,
      auto_start_watch_mode = false,
      -- bin_path = utils.find_tsc_bin(),
      enable_progress_notifications = true,
      -- flags = {
      --   noEmit = true,
      --   project = function()
      --     return utils.find_nearest_tsconfig()
      --   end,
      --   watch = false,
      -- },
      hide_progress_notifications_from_history = true,
      spinner = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
      pretty_errors = true,
    })
  end,
  keys = {
    { "<leader>tc", "<cmd>TSC<cr>", desc = "Type Check" },
    {
      "<C-t>",
      function()
        local trouble = require("trouble")
        if trouble.is_open() then
          vim.cmd("TSCClose")
        else
          vim.cmd("TSCOpen")
        end
      end,
      desc = "Toggle TSC Quickfix",
    },
  },
}
