return {
  "nvim-neo-tree/neo-tree.nvim",
  requires = {
    "nvim-lua/plenary.nvim",
    -- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    window = {
      position = "right",
      mappings = {
        ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
        ["y"] = {
          function(state)
            local node = state.tree:get_node()
            local filename = node.name
            vim.fn.setreg("+", filename)
            vim.notify("Copied filename: " .. filename)
          end,
          desc = "Copy Filename to Clipboard",
        },
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()

            -- Use LazyVim.root() or your own root detection
            local root = require("lazyvim.util").root.get() -- same as LazyVim.root()
            local relpath = filepath:gsub("^" .. vim.pesc(root) .. "/", "")

            vim.fn.setreg("+", relpath)
            vim.notify("Copied relative filepath: " .. relpath)
          end,
          desc = "Copy Path (Relative to Root) to Clipboard",
        },
        ["zz"] = {
          function(state)
            local node = state.tree:get_node()
            vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), 0 })
            vim.cmd("normal! zz")
          end,
          desc = "Center the cursor line",
        },
        ["W"] = "close_all_nodes",
      },
    },
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
    },
    filesystem = {
      filtered_items = {
        visible = false, -- when true, they will just be displayed differently than normal items
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = true, -- only works on Windows for hidden files/directories
        hide_by_name = {
          -- "node_modules",
        },
        hide_by_pattern = { -- uses glob style patterns
          --"*.meta",
          --"*/src/*/tsconfig.json",
        },
        always_show = { -- remains visible even if other settings would normally hide it
          --".gitignored",
        },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          ".DS_Store",
          --"thumbs.db"
        },
        never_show_by_pattern = { -- uses glob style patterns
          --".null-ls_*",
        },
      },
    },
  },
}
