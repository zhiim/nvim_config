local ui_opts = vim.g.options.plugins.ui

return {
  -- animation
  {
    'sphamba/smear-cursor.nvim',
    enabled = vim.fn.has 'nvim-0.10.2' and ui_opts.components.smear_cursor
      or ui_opts.enable_all,
    opts = {
      smear_between_neighbor_lines = false,
    },
  },

  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'LspAttach',
    enabled = vim.fn.has 'nvim-0.10.0'
        and ui_opts.components.tiny_inline_diagnostic
      or ui_opts.enable_all,
    priority = 800, -- needs to be loaded in first
    config = function()
      -- Default configuration
      require('tiny-inline-diagnostic').setup {
        signs = {
          left = '',
          right = '',
          diag = '●',
          arrow = '  ',
          up_arrow = '  ',
          vertical = ' │',
          vertical_end = ' └',
        },
        hi = {
          error = 'DiagnosticError',
          warn = 'DiagnosticWarn',
          info = 'DiagnosticInfo',
          hint = 'DiagnosticHint',
          arrow = 'NonText',
          background = 'CursorLine',
          mixing_color = require('utils.util').get_hl('Normal').bg,
        },
        blend = {
          factor = 0.08,
        },
        options = {
          -- Show the source of the diagnostic.
          show_source = true,
          use_icons_from_diagnostic = true,
          multilines = {
            enabled = true,
          },
          -- Show all diagnostics on the cursor line.
          show_all_diags_on_cursorline = true,
          virt_texts = {
            -- Priority for virtual text display
            priority = 10000,
          },
        },
      }
      vim.diagnostic.config { virtual_text = false }
    end,
  },
}
