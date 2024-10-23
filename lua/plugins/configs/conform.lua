if not vim.g.enable_language_support then
  return {}
end
return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>fm',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  config = function()
    local conform = require 'conform'
    local formatterConfig = vim.fn.stdpath 'config' .. '/config_files/'

    conform.setup {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      --
      -- NOTE: define languages specificed formater here
      --
      formatters_by_ft = {
        -- use `:lua print(vim.bo.filetype)` to check filetype
        lua = { 'stylua' },
        css = { 'prettier' },
        html = { 'prettier' },
        markdown = { 'prettier' },
        json = { 'prettier' },
        python = { 'ruff_fix', 'ruff_format' },
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        toml = { 'taplo' },
        yaml = { 'prettier' },
        -- rust = { "rustfmt" },
      },
    }

    conform.formatters.ruff_fix = {
      args = {
        'check',
        '--fix',
        '--force-exclude',
        '--exit-zero',
        '--no-cache',
        '--config',
        formatterConfig .. 'ruff_format.toml',
        '--stdin-filename',
        '$FILENAME',
        '-',
      },
    }

    conform.formatters.ruff_format = {
      args = {
        'format',
        '--config',
        formatterConfig .. 'ruff_format.toml',
        '--stdin-filename',
        '$FILENAME',
        '-',
      },
    }

    conform.formatters.clang_format = {
      prepend_args = { '--style=file:' .. formatterConfig .. 'clang_format.yaml' },
    }
  end,
}
