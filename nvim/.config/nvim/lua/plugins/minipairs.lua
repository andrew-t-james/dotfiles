return {
  "echasnovski/mini.pairs",
  event = "VeryLazy",
  opts = {
    -- Your mini.pairs configuration here
    modes = { insert = true, command = false, terminal = false },
    mappings = {
      ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
      ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
      ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
      [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
      ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
      ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
      ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
      ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
      ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
    },
  },
  config = function(_, opts)
    local mini_pairs_loaded = false
    local original_mappings = opts.mappings

    local function load_mini_pairs()
      if not mini_pairs_loaded then
        require("mini.pairs").setup(opts)
        mini_pairs_loaded = true
      end
    end

    local function disable_mini_pairs()
      if mini_pairs_loaded then
        require("mini.pairs").setup({ mappings = {} })
      end
    end

    local function enable_mini_pairs()
      if mini_pairs_loaded then
        require("mini.pairs").setup({ mappings = original_mappings })
      end
    end

    -- Load mini.pairs on InsertEnter
    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = load_mini_pairs,
      once = true,
    })

    -- Disable mini.pairs during search
    vim.api.nvim_create_autocmd("CmdlineEnter", {
      pattern = "/",
      callback = function()
        disable_mini_pairs()
      end,
    })

    -- Re-enable mini.pairs after search
    vim.api.nvim_create_autocmd("CmdlineLeave", {
      pattern = "/",
      callback = function()
        enable_mini_pairs()
      end,
    })
  end,
}
