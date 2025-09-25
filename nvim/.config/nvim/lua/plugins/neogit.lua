return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    "ibhagwan/fzf-lua", -- optional
  },
  config = function()
    local neogit = require("neogit")

    neogit.setup({
      -- Hides the hints at the top of the status buffer
      disable_hint = false,
      -- Disables changing the buffer highlights based on where the cursor is.
      disable_context_highlighting = false,
      -- Disables signs for sections/items/hunks
      disable_signs = false,
      -- Offer to force push when branches diverge
      prompt_force_push = true,
      -- Changes what mode the Commit Editor starts in
      disable_insert_on_commit = "auto",
      -- File watcher settings
      filewatcher = {
        interval = 1000,
        enabled = true,
      },
      -- Graph style setting
      graph_style = "ascii",
      -- Date format settings
      commit_date_format = nil,
      log_date_format = nil,
      -- Show spinning animation for git commands
      process_spinner = false,
      -- Git services configuration
      git_services = {
        ["github.com"] = {
          pull_request = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
          commit = "https://github.com/${owner}/${repository}/commit/${oid}",
          tree = "https://${host}/${owner}/${repository}/tree/${branch_name}",
        },
        ["bitbucket.org"] = {
          pull_request = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
          commit = "https://bitbucket.org/${owner}/${repository}/commits/${oid}",
          tree = "https://bitbucket.org/${owner}/${repository}/branch/${branch_name}",
        },
        ["gitlab.com"] = {
          pull_request = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
          commit = "https://gitlab.com/${owner}/${repository}/-/commit/${oid}",
          tree = "https://gitlab.com/${owner}/${repository}/-/tree/${branch_name}?ref_type=heads",
        },
        ["azure.com"] = {
          pull_request = "https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}",
          commit = "",
          tree = "",
        },
      },
      -- Settings persistence
      remember_settings = true,
      use_per_project_settings = true,
      ignored_settings = {},
      -- Highlight configuration
      highlight = {
        italic = true,
        bold = true,
        underline = true,
      },
      -- Keymapping settings
      use_default_keymaps = true,
      auto_refresh = true,
      sort_branches = "-committerdate",
      commit_order = "topo",
      initial_branch_name = "",
      kind = "tab",
      -- Floating window configuration
      floating = {
        relative = "editor",
        width = 0.8,
        height = 0.7,
        style = "minimal",
        border = "rounded",
      },
      -- Line number settings
      disable_line_numbers = true,
      disable_relative_line_numbers = true,
      -- Console settings
      console_timeout = 2000,
      auto_show_console = true,
      auto_close_console = true,
      notification_icon = "󰊢",
      -- Status configuration
      status = {
        show_head_commit_hash = true,
        recent_commit_count = 10,
        HEAD_padding = 10,
        HEAD_folded = false,
        mode_padding = 3,
        mode_text = {
          M = "modified",
          N = "new file",
          A = "added",
          D = "deleted",
          C = "copied",
          U = "updated",
          R = "renamed",
          DD = "unmerged",
          AU = "unmerged",
          UD = "unmerged",
          UA = "unmerged",
          DU = "unmerged",
          AA = "unmerged",
          UU = "unmerged",
          ["?"] = "",
        },
      },
      -- Editor configurations
      commit_editor = {
        kind = "tab",
        show_staged_diff = true,
        staged_diff_split_kind = "split",
        spell_check = true,
      },
      commit_select_view = {
        kind = "tab",
      },
      commit_view = {
        kind = "vsplit",
        verify_commit = vim.fn.executable("gpg") == 1,
      },
      log_view = {
        kind = "tab",
      },
      rebase_editor = {
        kind = "auto",
      },
      reflog_view = {
        kind = "tab",
      },
      merge_editor = {
        kind = "auto",
      },
      preview_buffer = {
        kind = "floating_console",
      },
      popup = {
        kind = "split",
      },
      stash = {
        kind = "tab",
      },
      refs_view = {
        kind = "tab",
      },
      -- Signs configuration
      signs = {
        -- { CLOSED, OPENED }
        section = { "", "" },
        item = { "", "" },
        hunk = { "", "" },
      },
      -- Integrations
      integrations = {
        telescope = nil,
        diffview = nil,
        fzf_lua = true,
        mini_pick = nil,
        snacks = nil,
      },
      -- Sections configuration
      sections = {
        sequencer = {
          folded = false,
          hidden = false,
        },
        untracked = {
          folded = false,
          hidden = false,
        },
        unstaged = {
          folded = false,
          hidden = false,
        },
        staged = {
          folded = false,
          hidden = false,
        },
        stashes = {
          folded = true,
          hidden = false,
        },
        unpulled_upstream = {
          folded = true,
          hidden = false,
        },
        unmerged_upstream = {
          folded = false,
          hidden = false,
        },
        unpulled_pushRemote = {
          folded = true,
          hidden = false,
        },
        unmerged_pushRemote = {
          folded = false,
          hidden = false,
        },
        recent = {
          folded = true,
          hidden = false,
        },
        rebase = {
          folded = true,
          hidden = false,
        },
      },
      -- Mappings configuration
      mappings = {
        commit_editor = {
          ["q"] = "Close",
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
          ["<m-p>"] = "PrevMessage",
          ["<m-n>"] = "NextMessage",
          ["<m-r>"] = "ResetMessage",
        },
        commit_editor_I = {
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
        },
        rebase_editor = {
          ["p"] = "Pick",
          ["r"] = "Reword",
          ["e"] = "Edit",
          ["s"] = "Squash",
          ["f"] = "Fixup",
          ["x"] = "Execute",
          ["d"] = "Drop",
          ["b"] = "Break",
          ["q"] = "Close",
          ["<cr>"] = "OpenCommit",
          ["gk"] = "MoveUp",
          ["gj"] = "MoveDown",
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
          ["[c"] = "OpenOrScrollUp",
          ["]c"] = "OpenOrScrollDown",
        },
        rebase_editor_I = {
          ["<c-c><c-c>"] = "Submit",
          ["<c-c><c-k>"] = "Abort",
        },
        finder = {
          ["<cr>"] = "Select",
          ["<c-c>"] = "Close",
          ["<esc>"] = "Close",
          ["<c-n>"] = "Next",
          ["<c-p>"] = "Previous",
          ["<down>"] = "Next",
          ["<up>"] = "Previous",
          ["<tab>"] = "InsertCompletion",
          ["<c-y>"] = "CopySelection",
          ["<space>"] = "MultiselectToggleNext",
          ["<s-space>"] = "MultiselectTogglePrevious",
          ["<c-j>"] = "NOP",
          ["<ScrollWheelDown>"] = "ScrollWheelDown",
          ["<ScrollWheelUp>"] = "ScrollWheelUp",
          ["<ScrollWheelLeft>"] = "NOP",
          ["<ScrollWheelRight>"] = "NOP",
          ["<LeftMouse>"] = "MouseClick",
          ["<2-LeftMouse>"] = "NOP",
        },
        popup = {
          ["?"] = "HelpPopup",
          ["A"] = "CherryPickPopup",
          ["d"] = "DiffPopup",
          ["M"] = "RemotePopup",
          ["P"] = "PushPopup",
          ["X"] = "ResetPopup",
          ["Z"] = "StashPopup",
          ["i"] = "IgnorePopup",
          ["t"] = "TagPopup",
          ["b"] = "BranchPopup",
          ["B"] = "BisectPopup",
          ["w"] = "WorktreePopup",
          ["c"] = "CommitPopup",
          ["f"] = "FetchPopup",
          ["l"] = "LogPopup",
          ["m"] = "MergePopup",
          ["p"] = "PullPopup",
          ["r"] = "RebasePopup",
          ["v"] = "RevertPopup",
        },
        status = {
          ["j"] = "MoveDown",
          ["k"] = "MoveUp",
          ["o"] = "OpenTree",
          ["q"] = "Close",
          ["I"] = "InitRepo",
          ["1"] = "Depth1",
          ["2"] = "Depth2",
          ["3"] = "Depth3",
          ["4"] = "Depth4",
          ["Q"] = "Command",
          ["<tab>"] = "Toggle",
          ["za"] = "Toggle",
          ["zo"] = "OpenFold",
          ["x"] = "Discard",
          ["s"] = "Stage",
          ["S"] = "StageUnstaged",
          ["<c-s>"] = "StageAll",
          ["u"] = "Unstage",
          ["K"] = "Untrack",
          ["U"] = "UnstageStaged",
          ["y"] = "ShowRefs",
          ["$"] = "CommandHistory",
          ["Y"] = "YankSelected",
          ["<c-r>"] = "RefreshBuffer",
          ["<cr>"] = "GoToFile",
          ["<s-cr>"] = "PeekFile",
          ["<c-v>"] = "VSplitOpen",
          ["<c-x>"] = "SplitOpen",
          ["<c-t>"] = "TabOpen",
          ["{"] = "GoToPreviousHunkHeader",
          ["}"] = "GoToNextHunkHeader",
          ["[c"] = "OpenOrScrollUp",
          ["]c"] = "OpenOrScrollDown",
          ["<c-k>"] = "PeekUp",
          ["<c-j>"] = "PeekDown",
          ["<c-n>"] = "NextSection",
          ["<c-p>"] = "PreviousSection",
        },
      },
    })
  end,

  keys = {
    { "<leader>gg", "<cmd>Neogit<CR>", mode = { "n" }, desc = "Open Neogit" },
  },
}
