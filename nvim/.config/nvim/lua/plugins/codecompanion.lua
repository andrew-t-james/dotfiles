return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      extensions = {
        -- mcphub = {
        --   callback = "mcphub.extensions.codecompanion",
        --   opts = {
        --     show_result_in_chat = true, -- Show mcp tool results in chat
        --     make_vars = true, -- Convert resources to #variables
        --     make_slash_commands = true, -- Add prompts as /slash commands
        --   },
        -- },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "anthropic",
      },
      cmd = {
        adapter = "anthropic",
      },
    },
  },
  -- {
  --   "Davidyz/VectorCode",
  --   version = "*", -- optional, depending on whether you're on nightly or release
  --   build = "pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
  --   dependencies = { "nvim-lua/plenary.nvim" },
  -- },
  -- {
  --   "ravitemer/mcphub.nvim",
  --   build = "npm install -g mcp-hub@latest",
  --   config = function()
  --     require("mcphub").setup()
  --   end,
  -- },
}
