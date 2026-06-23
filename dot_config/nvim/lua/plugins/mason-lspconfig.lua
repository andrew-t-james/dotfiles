return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "bashls", -- bash-language-server
      "docker_compose_language_service", -- docker-compose-language-service
      "dockerls", -- dockerfile-language-server
      "eslint", -- eslint-lsp
      "graphql", -- graphql-language-service-cli
      "jsonls", -- json-lsp
      "lua_ls", -- lua-language-server
      "pyright", -- pyright
      "rust_analyzer", -- rust-analyzer
      "tailwindcss", -- tailwindcss-language-server
      "templ", -- templ-language-server
      -- TypeScript: tsgo (native preview, npm) is the active server; vtsls kept as fallback
      "vtsls", -- vtsls
      "yamlls", -- yaml-language-server
    },
  },
}
