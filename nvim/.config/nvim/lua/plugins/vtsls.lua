return {
  "yioneko/nvim-vtsls",
  lazy = true,
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("vtsls").config({
      -- Global configuration for vtsls
      refactor_auto_rename = true,
    })
  end,
}
