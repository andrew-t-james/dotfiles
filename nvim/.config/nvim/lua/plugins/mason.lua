return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      -- Formatters
      "autopep8",
      "biome",
      "black",
      "prettier",
      "shfmt",
      "stylua",
      "yamlfmt",

      -- Linters
      "flake8",
      "luacheck",
      "shellcheck",
      "yamllint",

      -- Debug Adapters
      "debugpy",

      -- Other Tools
      "isort",
      "ruff",
    },
  },
}
