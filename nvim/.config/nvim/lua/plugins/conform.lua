local util = require("conform.util")

return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      oxfmt = {
        command = "oxfmt",
        args = { "--stdin-filepath", "$FILENAME" },
        stdin = true,
        require_cwd = true,
        cwd = util.root_file({ ".oxfmtrc.json", ".oxfmtrc.jsonc" }),
      },
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
      javascript = { "oxfmt", "biome", "prettier" },
      javascriptreact = { "oxfmt", "biome", "prettier" },
      typescript = { "oxfmt", "biome", "prettier" },
      typescriptreact = { "oxfmt", "biome", "prettier" },

      -- Data/Config files
      json = { "oxfmt", "biome", "prettier" },
      jsonc = { "oxfmt", "biome", "prettier" },
      yaml = { "oxfmt", "biome", "prettier" },

      -- Web files
      vue = { "oxfmt", "biome", "prettier" },
      css = { "oxfmt", "biome", "prettier" },
      scss = { "oxfmt", "biome", "prettier" },
      less = { "oxfmt", "biome", "prettier" },
      html = { "oxfmt", "biome", "prettier" },

      -- Documentation
      markdown = { "oxfmt", "biome", "prettier" },
      ["markdown.mdx"] = { "oxfmt", "biome", "prettier" },

      -- Other formats
      graphql = { "oxfmt", "biome", "prettier" },
      handlebars = { "oxfmt", "biome", "prettier" },
      go = { "goimports", "gofumpt" },
      templ = {
        "templ",
        "injected",
      },
    },
  },
}
