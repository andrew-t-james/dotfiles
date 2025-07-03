local util = require("conform.util")

return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      biome = {
        require_cwd = true,
        command = util.from_node_modules("biome"),
        args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
        stdin = true,
      },
      prettier = {
        require_cwd = true,
      },
      stylua = {
        prepend_args = { "--config-path", vim.fn.expand("~/.config/nvim/stylua.toml") },
      },
    },
    formatters_by_ft = {
      -- Lua files
      lua = { "stylua" },

      -- JavaScript/TypeScript ecosystem
      javascript = { "biome", "prettier" },
      javascriptreact = { "biome", "prettier" },
      typescript = { "biome", "prettier" },
      typescriptreact = { "biome", "prettier" },

      -- Data/Config files
      json = { "biome", "prettier" },
      jsonc = { "biome", "prettier" },
      yaml = { "biome", "prettier" },

      -- Web files
      vue = { "biome", "prettier" },
      css = { "biome", "prettier" },
      scss = { "biome", "prettier" },
      less = { "biome", "prettier" },
      html = { "biome", "prettier" },

      -- Documentation
      markdown = { "biome", "prettier" },
      ["markdown.mdx"] = { "biome", "prettier" },

      -- Other formats
      graphql = { "biome", "prettier" },
      handlebars = { "biome", "prettier" },
    },
  },
}
