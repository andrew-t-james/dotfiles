return {
  "neovim/nvim-lspconfig",
  enabled = true,
  opts = function(_, opts)
    opts = opts or {}
    opts.inlay_hints = { enabled = false }
    opts.servers = opts.servers or {}
    opts.servers.templ = {}
    -- Note: TypeScript servers (tsserver, ts_ls, vtsls) are configured in typescript.lua
    return opts
  end,
}
