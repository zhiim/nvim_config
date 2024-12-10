return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    -- NOTE: set linter for different file here
    lint.linters_by_ft = {
      -- python = { 'ruff' },
      json = { 'jsonlint' },
      yaml = { 'yamllint' },
    }

    -- local linterConfig = vim.fn.stdpath 'config' .. '/config_files/'

    -- lint.linters.ruff.args = {
    --   'check',
    --   '--force-exclude',
    --   '--quiet',
    --   '--stdin-filename',
    --   vim.api.nvim_buf_get_name(0),
    --   '--no-fix',
    --   '--output-format',
    --   'json',
    --   '--config',
    --   linterConfig .. 'ruff_lint.toml',
    --   '-',
    -- }

    -- lint.linters.yamllint.args = {
    --   '-c',
    --   linterConfig .. 'yamllint.yaml',
    --   '--format',
    --   'parsable',
    --   '-',
    -- }

    -- Create autocommand which carries out the actual linting
    -- on the specified events.
    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        require('lint').try_lint()
      end,
    })
  end,
}
