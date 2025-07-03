local function get_adapters()
  local cwd = vim.fn.getcwd()
  local adapters = {}

  -- Check for Python project
  if vim.fn.filereadable(cwd .. "/pyproject.toml") ~= 0 or vim.fn.filereadable(cwd .. "/requirements.txt") ~= 0 then
    -- Check for pytest first
    local pytest_files = {
      "pytest.ini",
      "conftest.py",
      "pyproject.toml", -- Often contains pytest config
    }

    local is_pytest = false
    for _, file in ipairs(pytest_files) do
      if vim.fn.filereadable(cwd .. "/" .. file) == 1 then
        is_pytest = true
        break
      end
    end

    table.insert(
      adapters,
      require("neotest-python")({
        runner = is_pytest and "pytest" or "unittest",
        python = cwd .. "/venv/bin/python",
        args = is_pytest and { "-v", "--color=yes" } or { "-v" },
        -- Add test file detection for unittest
        is_test_file = function(file_path)
          local file_name = vim.fn.fnamemodify(file_path, ":t")
          return file_name:match("^test_.*%.py$")
            or file_name:match("_test%.py$")
            or file_name == "test.py"
            or file_name == "tests.py"
        end,
      })
    )
  end

  -- Check for JS project using package.json
  local package_json = cwd .. "/package.json"

  if vim.fn.filereadable(package_json) ~= 0 then
    local package_contents = table.concat(vim.fn.readfile(package_json), "")

    -- Check for Jest
    if string.find(package_contents, "jest") then
      table.insert(
        adapters,
        require("neotest-jest")({
          jestCommand = "npm test --",
          jestConfigFile = "custom.jest.config.ts",
          env = { CI = true },
          cwd = function()
            return cwd
          end,
        })
      )
    end

    -- Check for Vitest
    if string.find(package_contents, "vitest") then
      table.insert(adapters, require("neotest-vitest")({}))
    end
  end

  return adapters
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-python",
    },
    keys = {
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last Test",
      },
      {
        "<leader>tL",
        function()
          require("neotest").run.run_last({ strategy = "dap" })
        end,
        desc = "Debug Last Test",
      },
      {
        "<leader>tw",
        "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>",
        desc = "Run Watch",
      },
    },
    opts = function(_, opts)
      local adapters = get_adapters()
      for _, adapter in ipairs(adapters) do
        table.insert(opts.adapters, adapter)
      end
    end,
  },
}
