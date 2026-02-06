local language_opts = vim.g.options.plugins.language

return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  enabled = vim.fn.has 'nvim-0.10' and language_opts.components.basic.enabled
    or language_opts.enable_all,
  cmd = { 'ConformInfo', 'FormatDisable', 'FormatEnable' },
  config = function()
    local conform = require 'conform'
    -- local formatterConfig = vim.fn.stdpath 'config' .. '/config_files/'

    local formatters_by_ft = {
      lua = { 'stylua' },
      css = { 'prettier' },
      html = { 'prettier' },
      javascript = { 'prettier' },
      markdown = { 'prettier' },
      json = { 'prettier' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      toml = { 'taplo' },
      yaml = { 'prettier' },
      cmake = { 'cmake_format' },
    }

    local fmt_opts = vim.g.options.plugins.language.components.basic.formatter
    if not fmt_opts.use_all then
      local formatters_settings = fmt_opts.formatters

      local function filter(formatters)
        local result = {}
        for _, f in ipairs(formatters) do
          if formatters_settings[f] then
            table.insert(result, f)
          end
        end
        return #result > 0 and result or nil
      end

      for ft, fmts in pairs(formatters_by_ft) do
        formatters_by_ft[ft] = filter(fmts)
      end
    end

    if
      language_opts.components.basic.lsp_server.use_all
      or language_opts.components.basic.lsp_server.servers['ruff']
    then
      formatters_by_ft.python = { 'ruff_fix', 'ruff_format' }
    end
    if vim.g.options.plugins.tex then
      formatters_by_ft.tex = { 'latexindent' }
    end

    conform.setup {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      -- NOTE: define languages specificed formater here
      formatters_by_ft = formatters_by_ft,
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
  end,
}
