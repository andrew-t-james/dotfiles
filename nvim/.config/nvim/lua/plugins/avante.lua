return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  -- version = false, -- set this if you want to always pull the latest change
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  opts = {
    -- add any opts here
    mappings = {
      ask = "<leader>ua", -- ask
      edit = "<leader>ue", -- edit
      refresh = "<leader>ur", -- refresh
    },
  },
  keys = {
    {
      "<leader>ua",
      function()
        require("avante.api").ask()
      end,
      desc = "avante: ask",
      mode = { "n", "v" },
    },
    {
      "<leader>ur",
      function()
        require("avante.api").refresh()
      end,
      desc = "avante: refresh",
      mode = "v",
    },
    {
      "<leader>ue",
      function()
        require("avante.api").edit()
      end,
      desc = "avante: edit",
      mode = { "n", "v" },
    },
  },
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
