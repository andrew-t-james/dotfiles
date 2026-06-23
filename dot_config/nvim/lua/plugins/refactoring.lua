-- LazyVim's refactoring extra:
--   1. is missing a hard dep on lewis6991/async.nvim (introduced in
--      refactoring.nvim commit 649a53c, Oct 2025).
--   2. still calls `telescope.load_extension("refactoring")`, but recent
--      refactoring.nvim no longer ships a telescope extension — load fails.
return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "lewis6991/async.nvim",
  },
  config = function(_, opts)
    require("refactoring").setup(opts)
  end,
}
