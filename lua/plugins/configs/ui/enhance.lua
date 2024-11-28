if vim.g.options.enhance then
  return {
    -- animation
    {
      'echasnovski/mini.animate',
      event = 'VeryLazy',
      config = function()
        require('mini.animate').setup {
          scroll = {
            enable = false,
          },
          cursor = {
            enable = false,
          },
        }
      end,
    },

    {
      'rachartier/tiny-inline-diagnostic.nvim',
      event = function()
        if vim.fn.has 'nvim-0.10' then
          return 'LspAttach'
        else
          return 'VeryLazy'
        end
      end,
      priority = 1000, -- needs to be loaded in first
      config = function()
        vim.diagnostic.config { virtual_text = false }
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
            factor = 0.18,
          },
          options = {
            -- Show the source of the diagnostic.
            show_source = true,
            -- If multiple diagnostics are under the cursor, display all of them.
            multiple_diag_under_cursor = true,
            -- Enable diagnostic message on all lines.
            multilines = true,
            -- Show all diagnostics on the cursor line.
            show_all_diags_on_cursorline = true,
            -- Enable diagnostics on Insert mode. You should also se the `throttle` option to 0, as some artefacts may appear.
            enable_on_insert = false,
          },
        }
      end,
    },
  }
else
  return {}
end
