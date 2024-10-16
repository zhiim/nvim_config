if not vim.g.enable_language_support then
  return {}
end
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    --
    -- NOTE: set linter for different file here
    --
    lint.linters_by_ft = {
      python = { 'ruff' },
      json = { 'jsonlint' },
      yaml = { 'yamllint' },
    }

    vim.keymap.set('n', '<leader>lt', function()
      lint.try_lint()
    end, { desc = 'Trigger linting for current file' })

    local linterConfig = vim.fn.stdpath 'config' .. '/config_files/'

    lint.linters.ruff.args = {
      'check',
      '--force-exclude',
      '--quiet',
      '--stdin-filename',
      vim.api.nvim_buf_get_name(0),
      '--no-fix',
      '--output-format',
      'json',
      '--config',
      linterConfig .. 'ruff_lint.toml',
      '-',
    }

    lint.linters.yamllint.args = {
      '-c',
      linterConfig .. 'yamllint.yaml',
      '--format',
      'parsable',
      '-',
    }

    -- To allow other plugins to add linters to require('lint').linters_by_ft,
    -- instead set linters_by_ft like this:
    -- lint.linters_by_ft = lint.linters_by_ft or {}
    -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
    --
    -- However, note that this will enable a set of default linters,
    -- which will cause errors unless these tools are available:
    -- {
    --   clojure = { "clj-kondo" },
    --   dockerfile = { "hadolint" },
    --   inko = { "inko" },
    --   janet = { "janet" },
    --   json = { "jsonlint" },
    --   markdown = { "vale" },
    --   rst = { "vale" },
    --   ruby = { "ruby" },
    --   terraform = { "tflint" },
    --   text = { "vale" }
    -- }
    --
    -- You can disable the default linters by setting their filetypes to nil:
    -- lint.linters_by_ft['clojure'] = nil
    -- lint.linters_by_ft['dockerfile'] = nil
    -- lint.linters_by_ft['inko'] = nil
    -- lint.linters_by_ft['janet'] = nil
    -- lint.linters_by_ft['json'] = nil
    -- lint.linters_by_ft['markdown'] = nil
    -- lint.linters_by_ft['rst'] = nil
    -- lint.linters_by_ft['ruby'] = nil
    -- lint.linters_by_ft['terraform'] = nil
    -- lint.linters_by_ft['text'] = nil

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
