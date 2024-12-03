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
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
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
        cmake = { 'cmake_format' },
        tex = { 'latexindent' },
        -- rust = { "rustfmt" },
      },
    }

    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = 'Disable autoformat-on-save',
      bang = true,
    })
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Re-enable autoformat-on-save',
    })

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
