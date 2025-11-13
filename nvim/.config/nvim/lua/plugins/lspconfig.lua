return {
  "neovim/nvim-lspconfig",
  enabled = true,
  opts = function(_, opts)
    opts = opts or {}
    opts.inlay_hints = { enabled = false }
    opts.servers = opts.servers or {}
    opts.servers.templ = {}
    return opts
  end,
}
