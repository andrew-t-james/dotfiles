return {
  "neovim/nvim-lspconfig",
  enabled = true,
  opts = function(_, opts)
    opts = opts or {}
    opts.inlay_hints = { enabled = false }
    opts.servers = opts.servers or {}
    opts.servers.templ = {}
    opts.servers.tsserver = { enabled = false }
    opts.servers.vtsls = { enabled = false }
    opts.servers.tsgo = {
      cmd = { "tsgo", "--lsp", "--stdio" },
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      root_markers = {
        "tsconfig.json",
        "jsconfig.json",
        "package.json",
        ".git",
        "tsconfig.base.json",
      },
      enabled = true,
    }
    return opts
  end,
}
