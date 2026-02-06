local language_opts = vim.g.options.plugins.language

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  enabled = vim.fn.has 'nvim-0.9.5' and language_opts.components.basic.enabled
    or language_opts.enable_all,
  config = function()
    local linter_opts = vim.g.options.plugins.language.components.basic.linter

    local linters_by_ft = {
      -- python = { 'ruff' },
      json = { 'jsonlint' },
      yaml = { 'yamllint' },
    }
    if not linter_opts.use_all then
      local linters_settings = linter_opts.linters

      local function filter(linters)
        local result = {}
        for _, l in ipairs(linters) do
          if linters_settings[l] then
            table.insert(result, l)
          end
        end
        return #result > 0 and result or nil
      end

      for ft, lnts in pairs(linters_by_ft) do
        linters_by_ft[ft] = filter(lnts)
      end
    end

    local lint = require 'lint'
    -- NOTE: set linter for different file here
    lint.linters_by_ft = linters_by_ft

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
