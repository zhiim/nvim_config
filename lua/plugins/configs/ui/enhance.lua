if vim.g.options.enhance then
  return {
    -- animation
    {
      'echasnovski/mini.animate',
      event = 'VeryLazy',
      config = function()
        -- don't use animate when scrolling with the mouse
        local mouse_scrolled = false
        for _, scroll in ipairs { 'Up', 'Down' } do
          local key = '<ScrollWheel' .. scroll .. '>'
          vim.keymap.set({ '', 'i' }, key, function()
            mouse_scrolled = true
            return key
          end, { expr = true })
        end

        vim.api.nvim_create_autocmd('FileType', {
          pattern = 'grug-far',
          callback = function()
            vim.b.minianimate_disable = true
          end,
        })

        local animate = require 'mini.animate'
        require('mini.animate').setup {
          resize = {
            timing = animate.gen_timing.linear { duration = 100, unit = 'total' },
          },
          scroll = {
            timing = animate.gen_timing.linear { duration = 250, unit = 'total' },
            subscroll = animate.gen_subscroll.equal {
              predicate = function(total_scroll)
                if mouse_scrolled then
                  mouse_scrolled = false
                  return false
                end
                return total_scroll > 1
              end,
            },
          },
          cursor = {
            -- enable = false,
            timing = animate.gen_timing.exponential {
              duration = 250,
              unit = 'total',
            },
          },
          open = {
            enable = true,
          },
          close = {
            enable = true,
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
      priority = 800, -- needs to be loaded in first
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
            factor = 0.1,
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
