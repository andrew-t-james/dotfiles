return {
  "philosofonusus/ecolog.nvim",
  keys = {
    { "<leader>il", "<Cmd>EcologShelterLinePeek<cr>", desc = "Ecolog peek line" },
    { "<leader>ih", "<Cmd>EcologShellToggle<cr>", desc = "Toggle shell variables" },
    { "<leader>ii", "<Cmd>EcologInterpolationToggle<cr>", desc = "Toggle shell variables" },
    { "<leader>ge", "<cmd>EcologGoto<cr>", desc = "Go to env file" },
    { "<leader>ic", "<cmd>EcologSnacks<cr>", desc = "Open a picker" },
    { "<leader>iS", "<cmd>EcologSelect<cr>", desc = "Switch env file" },
    { "<leader>is", "<cmd>EcologShelterToggle<cr>", desc = "Ecolog shelter toggle" },
  },
  lazy = false,
  opts = {
    preferred_environment = "local",
    types = true,
    providers = {
      {
        pattern = "{{[%w_]+}}?$",
        filetype = "http",
        extract_var = function(line, col)
          local utils = require("ecolog.utils")
          return utils.extract_env_var(line, col, "{{([%w_]+)}}?$")
        end,
        get_completion_trigger = function()
          return "{{"
        end,
      },
    },
    interpolation = {
      enabled = true,
      features = {
        commands = false,
      },
    },
    sort_var_fn = function(a, b)
      if a.source == "shell" and b.source ~= "shell" then
        return false
      end
      if a.source ~= "shell" and b.source == "shell" then
        return true
      end

      return a.name < b.name
    end,
    integrations = {
      lspsaga = true,
      blink_cmp = true,
      statusline = {
        hidden_mode = true,
        highlights = {
          env_file = "Directory",
          vars_count = "Number",
        },
      },
      snacks = true,
    },
    shelter = {
      configuration = {
        sources = {
          [".env.example"] = "none",
        },
        partial_mode = {
          min_mask = 5,
          show_start = 1,
          show_end = 1,
        },
        mask_char = "*",
      },
      modules = {
        files = true,
        peek = false,
        snacks_previewer = true,
        snacks = false,
        cmp = true,
      },
    },
    path = vim.fn.getcwd(),
  },
}
