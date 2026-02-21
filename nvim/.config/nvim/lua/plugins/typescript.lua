return {
  "neovim/nvim-lspconfig",
  enabled = true,
  opts = function(_, opts)
    opts = opts or {}
    opts.inlay_hints = { enabled = false }
    opts.servers = opts.servers or {}

    -- Disable tsserver/ts_ls in favor of vtsls
    opts.servers.tsserver = { enabled = false }
    opts.servers.ts_ls = { enabled = false }

    local ts_filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    }

    local function ts_code_action(kinds)
      local only = type(kinds) == "table" and kinds or { kinds }
      return function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            diagnostics = {},
            only = only,
          },
        })
      end
    end

    local function ts_keys()
      return {
        {
          "gD",
          function()
            local params = vim.lsp.util.make_position_params()
            LazyVim.lsp.execute({
              command = "typescript.goToSourceDefinition",
              arguments = { params.textDocument.uri, params.position },
              open = true,
            })
          end,
          desc = "Goto Source Definition",
        },
        {
          "gR",
          function()
            LazyVim.lsp.execute({
              command = "typescript.findAllFileReferences",
              arguments = { vim.uri_from_bufnr(0) },
              open = true,
            })
          end,
          desc = "File References",
        },
        {
          "<leader>co",
          ts_code_action({
            "source.organizeImports",
            "source.organizeImports.ts",
          }),
          desc = "Organize Imports",
        },
        {
          "<leader>ci",
          ts_code_action({
            "source.addMissingImports",
            "source.addMissingImports.ts",
          }),
          desc = "Add missing imports",
        },
        {
          "<leader>cu",
          ts_code_action({
            "source.removeUnused",
            "source.removeUnused.ts",
          }),
          desc = "Remove unused imports",
        },
        {
          "<leader>cD",
          ts_code_action({
            "source.fixAll",
            "source.fixAll.ts",
          }),
          desc = "Fix all diagnostics",
        },
        {
          "<leader>cV",
          function()
            LazyVim.lsp.execute({ command = "typescript.selectTypeScriptVersion" })
          end,
          desc = "Select TS workspace version",
        },
      }
    end

    -- Configure vtsls (recommended TypeScript LSP)
    opts.servers.vtsls = {
      enabled = true,
      filetypes = ts_filetypes,
      settings = {
        complete_function_calls = true,
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            maxInlayHintLength = 30,
            completion = {
              enableServerSideFuzzyMatch = true,
            },
          },
        },
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
          suggest = {
            completeFunctionCalls = true,
          },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
      },
      keys = ts_keys(),
    }

    -- Setup function to ensure javascript settings mirror typescript
    opts.setup = opts.setup or {}
    opts.setup.vtsls = function(_, server_opts)
      server_opts.settings = server_opts.settings or {}
      if server_opts.settings.typescript then
        server_opts.settings.javascript = vim.tbl_deep_extend(
          "force",
          {},
          server_opts.settings.typescript,
          server_opts.settings.javascript or {}
        )
      end
    end

    return opts
  end,
}
