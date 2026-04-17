return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          -- https://github.com/HiPhish/rainbow-delimiters.nvim/issues/6
          -- disable jsx/html form getting rainbow delimiters
          javascript = "rainbow-parens",
          tsx = "rainbow-parens",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterViolet",
          "RainbowDelimiterGreen",
          "RainbowDelimiterOrange",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
}
